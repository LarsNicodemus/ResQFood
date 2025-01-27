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
    var unreadMessagesCount: Int {
        return unreadCountPerChat.values.reduce(0, +)
    }
    @Published var userProfile: UserProfile? = nil
    @Published var unreadMessagesCounts: [String: Int] = [:]
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
    
    var currentUserID: String {
        fb.userID ?? ""
    }

    private let repo = ChatRepositoryImplementation()
    private let userRepo = UserRepositoryImplementation()
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    private var unreadListener: ListenerRegistration?
    private var memberListener: ListenerRegistration?
    private var chatListeners: [String: ListenerRegistration] = [:]


    deinit {
        listener?.remove()
        listener = nil
        unreadListener?.remove()
        unreadListener = nil
        memberListener?.remove()
        memberListener = nil
        userProfile = nil
        chatListeners.values.forEach { $0.remove() }
        chatListeners.removeAll()
    }

    /// Ruft das Profil eines anderen Benutzers basierend auf der Benutzer-ID ab.
    /// - Parameters:
    ///   - id: Die ID des anderen Benutzers.
    /// - Updates: `userProfile` mit den abgerufenen Profildaten.
    func getOtherUserByID(id: String) {
        memberListener = userRepo.addProfileListener(userID: id) { profile in
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
        memberListener = userRepo.addProfileListener(userID: id) { profile in
            print("Member Listener Update: \(profile?.username ?? "nil")")
            self.chatUsernames[chatID] = profile?.username
        }
    }

    /// Startet einen Listener für ungelesene Nachrichten in einem bestimmten Chat.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    /// - Updates: `unreadMessagesCounts` mit der Anzahl der ungelesenen Nachrichten im Chat.
    func startUnreadMessagesListenerForChat(chatID: String) {
        guard let currentID = fb.userID else { return }
        chatListeners[chatID]?.remove()
        chatListeners[chatID] = repo.listenForUnreadMessages(
            chatID: chatID, userID: currentID
        ) { [weak self] count in
            DispatchQueue.main.async {
                self?.unreadMessagesCounts[chatID] = count
                print("for \(chatID) \(count)")
            }
        }
    }
    
    /// Startet einen Listener für ungelesene Nachrichten-Abzeichen.
    /// - Updates: `unreadCountPerChat` mit der Anzahl der ungelesenen Nachrichten in allen Chats.
    func unreadMessagesBadgeListener() {
        addChatsSnapshotListener()
        if !chats.isEmpty {
            var remainingCalls = chats.count
            
            for chat in chats {
                startUnreadMessagesListenerForBadge(chatID: chat.id) {
                    remainingCalls -= 1
                    
                    if remainingCalls == 0 {
                        print("UnredCount: \(self.unreadMessagesCount)")
                    }
                }
            }
        } else {
            print("Chats Empty")
        }
    }
    
    /// Startet einen Listener für ungelesene Nachrichten-Abzeichen in einem bestimmten Chat.
    /// - Parameters:
    ///   - chatID: Die ID des Chats.
    ///   - completion: Callback nach dem Aktualisieren der ungelesenen Nachrichten.
    /// - Updates: `unreadCountPerChat` mit der Anzahl der ungelesenen Nachrichten im Chat.
    func startUnreadMessagesListenerForBadge(chatID: String, completion: @escaping () -> Void) {
        guard let currentID = fb.userID else { return }
        chatListeners[chatID]?.remove()
        chatListeners[chatID] = repo.listenForUnreadMessages(
            chatID: chatID, userID: currentID
        ) { [weak self] count in
            DispatchQueue.main.async {
                self?.unreadCountPerChat[chatID] = count
                self?.objectWillChange.send()
                completion()
            }
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

    /// Fügt einen Snapshot-Listener für die Chats des Benutzers hinzu.
    /// - Updates: `chats` mit den abgerufenen Chats, sortiert nach der letzten Nachricht.
    func addChatsSnapshotListener() {
        guard let userID = fb.userID else {return}
        listener = repo.userChatsListener(userID: userID) { chats in
            self.chats = chats.sorted(by: { c1, c2 in
                c1.lastMessage > c2.lastMessage
            }
            )
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
        unreadListener?.remove()
        unreadListener = nil
        memberListener?.remove()
        memberListener = nil
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
