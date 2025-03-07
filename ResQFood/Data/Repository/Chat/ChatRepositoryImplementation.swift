//
//  ChatRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import FirebaseFirestore

class ChatRepositoryImplementation: ChatRepository {
    private let fb = FirebaseService.shared
    private let db = FirebaseService.shared.database
    
    /// Erstellt einen Listener für alle Chats eines Benutzers
    /// - Parameters:
    ///   - userID: ID des Benutzers
    ///   - completion: Callback mit Array aller Chats
    /// - Returns: ListenerRegistration zum späteren Entfernen
    func userChatsListener(
        userID: String, completion: @escaping ([Chat]) -> Void
    ) -> any ListenerRegistration {
        let userListener = db.collection("users").document(userID)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self,
                    let document = documentSnapshot
                else {
                    print(
                        "Error fetching user: \(error?.localizedDescription ?? "")"
                    )
                    return
                }

                guard let user = try? document.data(as: AppUser.self),
                    !user.chatIDs.isEmpty
                else {
                    completion([])
                    return
                }
                self.chatListener(
                    chatIDs: Array(user.chatIDs), completion: completion)
            }

        return userListener
    }
    
    /// Überwacht ungelesene Nachrichten in einem Chat
    /// - Parameters:
    ///   - chatID: ID des zu überwachenden Chats
    ///   - userID: ID des Benutzers
    ///   - completion: Callback mit der Anzahl ungelesener Nachrichten
    /// - Returns: ListenerRegistration zum späteren Entfernen
    func listenForUnreadMessages(
        chatID: String,
        userID: String,
        completion: @escaping (Int) -> Void
    ) -> ListenerRegistration {
        return db.collection("chats")
            .document(chatID)
            .collection("messages")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(
                        "Error fetching messages for chat \(chatID): \(error.localizedDescription)"
                    )
                    return
                }

                guard let documents = querySnapshot?.documents else { return }

                let unreadMessages = documents.filter { document in
                    if let message = try? document.data(as: Message.self) {
                        return message.isread[userID] == false
                    }
                    return false
                }
                completion(unreadMessages.count)
            }
    }
    
    

    /// Erstellt einen neuen Chat zwischen zwei Benutzern
    /// - Parameters:
    ///   - name: Name des Chats
    ///   - userID: ID des anderen Chat-Teilnehmers
    ///   - content: Inhalt der ersten Nachricht
    ///   - donationID: ID der zugehörigen Spende
    func createChat(name: String, userID: String, content: String, donationID: String?) {
        guard let id = fb.auth.currentUser?.uid else { return }
        guard let donationID = donationID else { return }
        let chat = Chat(members: [id, userID], admin: userID, name: name, donationID: donationID)

        do {
            try fb.database.collection("chats")
                .document(chat.id)
                .setData(from: chat)
        } catch {
            print("Error creating Chat: \(error.localizedDescription)")
            return
        }
        updateChatIDs(for: [id, userID], chatID: chat.id)
        let message = Message(
            content: content, senderID: id, isread: [id: true, userID: false])
        do {
            try fb.database.collection("chats").document(chat.id).collection(
                "messages"
            ).addDocument(from: message) { error in
                if let error = error {
                    print(
                        "Error adding initial message: \(error.localizedDescription)"
                    )
                }
            }
        } catch {
            print(error)
        }
    }

    /// Aktualisiert die Chat-IDs der beteiligten Benutzer
    /// - Parameters:
    ///   - userIDs: Array der Benutzer-IDs
    ///   - chatID: ID des Chats der hinzugefügt werden soll
    func updateChatIDs(for userIDs: [String], chatID: String) {
        for userID in userIDs {
            fb.database.collection("users").document(userID).updateData([
                "chatIDs": FieldValue.arrayUnion([chatID])
            ]) { error in
                if let error = error {
                    print(
                        "Error updating chatIDs for user \(userID): \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// Sendet eine neue Nachricht in einem Chat
    /// - Parameters:
    ///   - chatID: ID des Chats
    ///   - content: Inhalt der Nachricht
    func sendMessage(chatID: String, content: String) {
        guard let senderID = fb.auth.currentUser?.uid else { return }
        let chatRef = fb.database.collection("chats").document(chatID)
        chatRef.getDocument { document, error in
            if let document = document, document.exists {
                let members = document.data()?["members"] as? [String] ?? []
                var isread = [String: Bool]()
                for member in members {
                    isread[member] = (member == senderID)
                }
                let message = Message(
                    content: content, senderID: senderID, isread: isread)
                do {
                    try self.fb.database.collection("chats")
                        .document(chatID)
                        .collection("messages")
                        .addDocument(from: message)
                    chatRef.updateData(["lastMessage": message.timestamp])
                } catch {
                    print("Error sending message: \(error)")
                }
            } else {
                print(
                    "Error fetching chat document: \(error?.localizedDescription ?? "Unknown error")"
                )
            }
        }
    }

    /// Markiert eine Nachricht als gelesen für den aktuellen Benutzer
    /// - Parameters:
    ///   - chatID: ID des Chats
    ///   - messageID: ID der Nachricht
    func markMessageAsRead(chatID: String, messageID: String) {
        guard let id = fb.auth.currentUser?.uid else { return }

        let messageRef = fb.database.collection("chats")
            .document(chatID)
            .collection("messages")
            .document(messageID)
        messageRef.getDocument { document, error in
            if let document = document, document.exists {
                var isread =
                    document.data()?["isread"] as? [String: Bool] ?? [:]
                isread[id] = true
                messageRef.updateData(["isread": isread]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    /// Überwacht Änderungen an bestimmten Chats
    /// - Parameters:
    ///   - chatIDs: Array der zu überwachenden Chat-IDs
    ///   - completion: Callback mit Array der aktualisierten Chats
    func chatListener(chatIDs: [String], completion: @escaping ([Chat]) -> Void)
    {
        db.collection("chats")
            .whereField("id", in: chatIDs)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print(
                        "Error fetching chats: \(error?.localizedDescription ?? "")"
                    )
                    return
                }
                let chats = documents.compactMap { document -> Chat? in
                    try? document.data(as: Chat.self)
                }
                completion(chats)
            }
    }

    /// Erstellt einen Listener für Nachrichten in einem Chat
    /// - Parameters:
    ///   - chatID: ID des zu überwachenden Chats
    ///   - onSuccess: Callback mit Array aller Nachrichten
    /// - Returns: Optional ListenerRegistration zum späteren Entfernen
    func addMessageSnapshotListener(
        chatID: String, onSuccess: @escaping ([Message]) -> Void
    ) -> (any ListenerRegistration)? {
        return fb.database.collection("chats")
            .document(chatID)
            .collection("messages")
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let messages = documents.compactMap { snapShot in
                    return try? snapShot.data(as: Message.self)
                }
                onSuccess(messages)
            }
    }
}
