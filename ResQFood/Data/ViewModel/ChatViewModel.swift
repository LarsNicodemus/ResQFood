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

    var currentUserID: String {
        fb.userID ?? ""
    }

    private let repo = ChatRepositoryImplementation()
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    private let userRepo = UserRepositoryImplementation()

    
    
    deinit {
        listener?.remove()
        listener = nil

    }

    func getOtherUserByID(id: String) {
        listener = userRepo.addProfileListener(userID: id) { profile in
            print("Profile Listener Update: \(profile?.username ?? "nil")")
            self.userProfile = profile
        }
        }
    
    func startUnreadMessagesListener() {
        listener = repo.unreadMessagesCountListener(userID: currentUserID) { unreadCount in
                self.unreadMessagesCount = unreadCount
            }
        }

    func createChat(name: String, userID: String, donationID: String?) {
        repo.createChat(name: name, userID: userID, content: messageInput, donationID: donationID)
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
