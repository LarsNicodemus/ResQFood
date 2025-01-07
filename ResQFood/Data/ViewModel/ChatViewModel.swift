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

    var currentUserID: String {
        fb.userID ?? ""
    }

    private let repo = ChatRepositoryImplementation()
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
        listener = nil
    }

    func changeAdmin(chatID: String) {
        repo.changeAdmin(chatID: chatID, newAdminID: currentUserID)
    }

    func createChat(name: String) {
        repo.createChat(name: name)
    }
    
    func createChat3(name: String, userID: String) {
        repo.createChat2(name: name, userID: userID, content: messageInput)
        messageInput = ""
    }

    func sendMessage(chatID: String) {
        guard !messageInput.isEmpty else { return }
        repo.sendMessage(chatID: chatID, content: messageInput)
        messageInput = ""
    }
    func sendFirstMessage(
        name: String, title: String, userID: String
    ) async {
        guard !messageInput.isEmpty else { return }
        repo.createChat(name: name)
        guard let chatID = chats.first(where: {
                $0.name == title
            })?.id
        else { return }

        repo.addUserToChat(chatID: chatID, userID: userID)
        repo.sendMessage(
            chatID: chatID, content: "Betreff: \(title) \n + \(messageInput)")
        messageInput = ""
    }
    
    func sendFirstMessageCreateChat(name: String, title: String, userID: String){
        repo.createChatSentFirstMessage(name: name, userID: userID, content: messageInput)
        messageInput = ""
    }

    func addUserToChat(chatID: String, userID: String) {
        repo.addUserToChat(chatID: chatID, userID: userID)
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
                c1.creationDate > c2.creationDate
            })
        }
    }

    func loadChats() {
        repo.loadChats { chats in
            self.chats = chats
        }
    }

    func loadMessages(chatID: String) {
        repo.loadMessages(chatID: chatID) { messages in
            self.messages = messages
        }
    }

}
