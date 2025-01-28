//
//  ChatViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import FirebaseFirestore
import SwiftUI

class ChatViewModel: ObservableObject {
    
    @Published var chats: [Chat] = []
    @Published var messages: [Message] = []
    @Published var messageInput: String = ""
    @Published var userProfile: UserProfile? = nil
    @Published var chatUsernames: [String: String] = [:]
    @Published var lastMessagesContent: [String: String] = [:]
    @Published var lastMessagesSender: [String: String] = [:]
    @Published var unreadCountPerChat: [String: Int] = [:]
    @Published var showToast: Bool = false
    @Published var title: String? = nil
    @Published var chatMember: String = "Hasibububär"
    @Published var chatMemberID: String = ""
    @Published var donationID: String = ""
    @Published var details: Bool = false
    @Published var userCreator: Bool = false
    @Published var showToastDetails: Bool = false
    @Published var toastMessage: String = ""
    @Published var donationForTitle: FoodDonation? = nil
    
    var unreadMessagesCount: Int {
        return unreadCountPerChat.values.reduce(0, +)
    }
    
    var currentUserID: String {
        fb.userID ?? ""
    }

    private let repo = ChatRepositoryImplementation()
    private let userRepo = UserRepositoryImplementation()
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    private var chatListeners: [String: ListenerRegistration] = [:]


    deinit {
        deinitChat()
    }

   
    
    /// Startet einen Listener für die Chats eines Benutzers.
    /// - Description: Diese Funktion fügt einen Snapshot-Listener hinzu, der die Chats des Benutzers überwacht und bei Änderungen
    ///   die Liste der Chats aktualisiert sowie den Abzeichen-Zähler für ungelesene Nachrichten aktualisiert.
    /// - Parameters: Keine.
    /// - Updates: `chats` mit sortierten Chats nach dem letzten Nachrichtendatum und ruft `unreadMessagesBadgeListener` auf.
    func addChatsSnapshotListener() {
        guard let userID = fb.userID else { return }
        listener?.remove()
        listener = repo.userChatsListener(userID: userID) { chats in
            DispatchQueue.main.async {
                self.chats = chats.sorted(by: { c1, c2 in
                    c1.lastMessage > c2.lastMessage
                })
                self.unreadMessagesBadgeListener()
            }
        }
    }
    
    /// Startet einen Listener für ungelesene Nachrichten-Abzeichen für alle Chats des Benutzers.
    /// - Description: Diese Funktion überprüft, ob Chats vorhanden sind, und startet für jeden Chat einen Listener,
    ///   um die Anzahl der ungelesenen Nachrichten zu überwachen. Sobald alle Listener ihre Arbeit abgeschlossen haben,
    ///   wird die Gesamtanzahl der ungelesenen Nachrichten für alle Chats ausgegeben.
    /// - Parameters: Keine.
    /// - Updates: `unreadMessagesCount` mit der Gesamtanzahl der ungelesenen Nachrichten in allen Chats.
    func unreadMessagesBadgeListener() {
            if !chats.isEmpty {
                var remainingCalls = chats.count
                
                for chat in chats {
                    startUnreadMessagesListenerForBadge(chatID: chat.id) {
                        remainingCalls -= 1
                        
                        if remainingCalls == 0 {
                            print("UnreadCount: \(self.unreadMessagesCount)")
                        }
                    }
                }
            } else {
                print("Chats Empty")
            }
        }
    
    /// Startet einen Listener für ungelesene Nachrichten in einem bestimmten Chat und aktualisiert den Badge-Zähler.
    /// - Parameters:
    ///   - chatID: Die ID des Chats, für den der Listener gestartet werden soll.
    ///   - completion: Ein Callback, der nach dem Aktualisieren der Anzahl ungelesener Nachrichten aufgerufen wird.
    /// - Updates: `unreadCountPerChat`  mit der Anzahl der ungelesenen Nachrichten im Chat.
    func startUnreadMessagesListenerForBadge(chatID: String, completion: @escaping () -> Void) {
        guard let currentID = fb.userID else { return }
        chatListeners[chatID]?.remove()
        chatListeners[chatID] = repo.listenForUnreadMessages(
            chatID: chatID, userID: currentID
        ) { [weak self] count in
            DispatchQueue.main.async {
                self?.unreadCountPerChat[chatID] = count
                self?.objectWillChange.send()
                print("for \(chatID) \(count)")
                completion()
            }
        }
    }

    
    /// Ruft das Profil eines anderen Benutzers basierend auf der Benutzer-ID ab.
    /// - Parameters:
    ///   - id: Die ID des anderen Benutzers.
    /// - Updates: `userProfile` mit den abgerufenen Profildaten.
    func getOtherUserByID(id: String) {
        listener = userRepo.addProfileListener(userID: id) { profile in
            print("Member Listener Update: \(profile?.username ?? "nil")")
            self.userProfile = profile
        }
    }
    
    /// Ruft das Profil eines anderen Benutzers basierend auf der Benutzer-ID ab und aktualisiert die Benutzernamen in einem bestimmten Chat.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    ///   - id: Die ID des anderen Benutzers.
    /// - Updates: `chatUsernames` mit den Benutzernamen des abgerufenen Profils.
    func getOtherUserByIDList(chatID: String, id: String) {
        listener = userRepo.addProfileListener(userID: id) { profile in
            print("Member Listener Update: \(profile?.username ?? "nil")")
            self.chatUsernames[chatID] = profile?.username
        }
    }
    
    /// Erstellt einen neuen Chat mit einem bestimmten Namen, Benutzer-ID und optionaler Spenden-ID.
    /// - Parameters:
    ///   - name: Der Name des Chats.
    ///   - userID: Die ID des Benutzers.
    ///   - donationID: Die optionale Spenden-ID.
    /// - Clears: Setzt `messageInput` auf einen leeren String nach Erstellung des Chats.
    func createChat(name: String, userID: String, donationID: String?) {
        repo.createChat(
            name: name, userID: userID, content: messageInput,
            donationID: donationID)
        messageInput = ""
    }

    /// Sendet eine Nachricht in einem bestimmten Chat.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    /// - Clears: Setzt `messageInput` auf einen leeren String nach dem Senden der Nachricht.
    func sendMessage(chatID: String) {
        guard !messageInput.isEmpty else { return }
        repo.sendMessage(chatID: chatID, content: messageInput)
        messageInput = ""
    }

    /// Fügt einen Snapshot-Listener für Nachrichten in einem bestimmten Chat hinzu.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    /// - Updates: `messages` mit den abgerufenen Nachrichten, sortiert nach Zeitstempel.
    /// - Updates: `lastMessagesContent` und `lastMessagesSender` basierend auf der letzten Nachricht.
    func addMessageSnapshotListener(chatID: String) {
        listener = repo.addMessageSnapshotListener(chatID: chatID) { messages in
            self.messages = messages.sorted { m1, m2 in
                m1.timestamp > m2.timestamp
            }
            if let lastMessage = self.messages.first {
                self.lastMessagesContent[chatID] = lastMessage.content
                self.lastMessagesSender[chatID] = lastMessage.senderID
            } else {
                self.lastMessagesContent[chatID] = "Keine Nachrichten verfügbar"
                self.lastMessagesSender[chatID] = "Keine ID verfügbar"
            }
        }
    }

    /// Markiert eine Nachricht in einem bestimmten Chat als gelesen.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    ///   - messageID: Die ID der Nachricht.
    func markMessageAsRead(chatID: String, messageID: String) {
        repo.markMessageAsRead(chatID: chatID, messageID: messageID)
    }
    
    /// Entfernt alle Listener und setzt die Benutzerprofilinformationen zurück.
    func deinitChat() {
        listener?.remove()
        listener = nil
        userProfile = nil
        chatListeners.values.forEach { $0.remove() }
        chatListeners.removeAll()
    }
    
    func sendMessagefromDon(donation: FoodDonation){
        if !messageInput.isEmpty {
            
            createChat(
                name: donation.title,
                userID: donation.creatorID,
                donationID: donation.id)
            withAnimation {
                self.showToast = true
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2
            ) {
                withAnimation {
                    self.showToast = false
                }
            }
        }
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let formatter = DateFormatter()

        if isToday {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        }

        return formatter.string(from: date)
    }
}
