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
    @Published var unreadMessagesCount: Int = 0
    @Published var userProfile: UserProfile? = nil
    @Published var unreadMessagesCounts: [String: Int] = [:]
    @Published var chatUsernames: [String: String] = [:]

    var currentUserID: String {
        fb.userID ?? ""
    }

    private let repo = ChatRepositoryImplementation()
    private let userRepo = UserRepositoryImplementation()
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    private var memberListener: ListenerRegistration?
    private var chatListeners: [String: ListenerRegistration] = [:]

    deinit {
        listener?.remove()
        listener = nil
        memberListener?.remove()
        memberListener = nil
        userProfile = nil
        chatListeners.values.forEach { $0.remove() }
            chatListeners.removeAll()
    }

    func getOtherUserByID(id: String) {
        memberListener = userRepo.addProfileListener(userID: id) { profile in
            print("Member Listener Update: \(profile?.username ?? "nil")")
            self.userProfile = profile
        }
    }
    func getOtherUserByIDList(chatID: String, id: String) {
        memberListener = userRepo.addProfileListener(userID: id) { profile in
            print("Member Listener Update: \(profile?.username ?? "nil")")
            self.chatUsernames[chatID] = profile?.username
            
        }
    }

    func startUnreadMessagesListenerForChat(chatID: String) {
        guard let currentID = fb.userID else { return }
        chatListeners[chatID]?.remove()
        chatListeners[chatID] = repo.listenForUnreadMessages(chatID: chatID, userID: currentID) { [weak self] count in
                DispatchQueue.main.async {
                    self?.unreadMessagesCounts[chatID] = count
                }
            }
    }
    func startUnreadMessagesListener() {
        listener = repo.unreadMessagesCountListener(userID: currentUserID) {
            unreadCount in
            self.unreadMessagesCount = unreadCount
        }
    }

    func createChat(name: String, userID: String, donationID: String?) {
        repo.createChat(
            name: name, userID: userID, content: messageInput,
            donationID: donationID)
        messageInput = ""
    }

    func sendMessage(chatID: String) {
        guard !messageInput.isEmpty else { return }
        repo.sendMessage(chatID: chatID, content: messageInput)
        messageInput = ""
    }

    func addMessageSnapshotListener(chatID: String) {
        listener = repo.addMessageSnapshotListener(chatID: chatID) { messages in
            self.messages = messages.sorted { m1, m2 in
                m1.timestamp > m2.timestamp
            }
        }
    }

    func addChatsSnapshotListener() {
        listener = repo.userChatsListener(userID: currentUserID) { chats in
            self.chats = chats.sorted(by: { c1, c2 in
                c1.lastMessage > c2.lastMessage
            }
            )
        }
    }

    func markMessageAsRead(chatID: String, messageID: String) {
        repo.markMessageAsRead(chatID: chatID, messageID: messageID)
    }

}
