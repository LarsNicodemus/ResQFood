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

    func createChat(name: String) {
        guard let id = fb.auth.currentUser?.uid else { return }
        let chat = Chat(members: [id], admin: id, name: name)

        do {
            try fb.database.collection("chats")
                .document(chat.id)
                .setData(from: chat)

            fb.database.collection("users")
                .document(id)
                .updateData([
                    "chatIDs": FieldValue.arrayUnion([chat.id])
                ]) { error in
                    if let error = error {
                        print(
                            "Error updating user chatIDs: \(error.localizedDescription)"
                        )
                    }
                }
        } catch {
            print("Error creating Chat")
        }
    }

    func createChat2(name: String, userID: String, content: String) {
        guard let id = fb.auth.currentUser?.uid else { return }
        let chat = Chat(members: [id, userID], admin: id, name: name)

        do {
            try fb.database.collection("chats")
                .document(chat.id)
                .setData(from: chat)
        } catch {
            print("Error creating Chat: \(error.localizedDescription)")
            return
        }

        updateChatIDs(for: [id, userID], chatID: chat.id)

        let message = Message(content: content, senderID: id, isread: [id : true, userID : false])

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

    func createChatSentFirstMessage(
        name: String, userID: String, content: String
    ) {
        guard let id = fb.auth.currentUser?.uid else { return }
        let chat = Chat(members: [id], admin: id, name: name)

        do {
            try fb.database.collection("chats")
                .document(chat.id)
                .setData(from: chat)

            fb.database.collection("users")
                .document(id)
                .updateData([
                    "chatIDs": FieldValue.arrayUnion([chat.id])
                ]) { error in
                    if let error = error {
                        print(
                            "Error updating user chatIDs: \(error.localizedDescription)"
                        )
                    }
                }
        } catch {
            print("Error creating Chat")
        }
        fb.database.collection("chats")
            .document(chat.id)
            .updateData(["members": FieldValue.arrayUnion([userID])])
        let message = Message(content: content, senderID: id)
        do {
            try fb.database.collection("chats")
                .document(chat.id)
                .collection("messages")
                .addDocument(from: message)
        } catch {
            print(error)
        }
    }

    func addUserToChat(chatID: String, userID: String) {
        fb.database.collection("chats")
            .document(chatID)
            .updateData(["members": FieldValue.arrayUnion([userID])])
    }

    func removeUserFromChat(chatID: String, userID: String) {

    }

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

                let message = Message(content: content, senderID: senderID, isread: isread)

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
                print("Error fetching chat document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func markMessageAsRead(chatID: String, messageID: String) {
        guard let id = fb.auth.currentUser?.uid else { return }

        let messageRef = fb.database.collection("chats")
            .document(chatID)
            .collection("messages")
            .document(messageID)

        messageRef.getDocument { document, error in
            if let document = document, document.exists {
                var isread = document.data()?["isread"] as? [String: Bool] ?? [:]
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
    
    func unreadMessagesCountListener(userID: String, completion: @escaping (Int) -> Void) -> ListenerRegistration {
        return db.collection("users")
            .document(userID)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }

                guard let document = documentSnapshot,
                      let data = document.data(),
                      let chatIDs = data["chatIDs"] as? [String] else {
                    print("No chatIDs found for user.")
                    return
                }
                
                var unreadCount = 0
                for chatID in chatIDs {
                    self.listenForUnreadMessages(chatID: chatID, userID: userID) { count in
                        unreadCount += count
                        completion(unreadCount)
                    }
                }
            }
    }
    
    private func listenForUnreadMessages(chatID: String, userID: String, completion: @escaping (Int) -> Void) {
        db.collection("chats")
            .document(chatID)
            .collection("messages")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching messages for chat \(chatID): \(error.localizedDescription)")
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

    //    func addChatSnapshotListener(
    //        chatID: String, userID: String, onSuccess: @escaping ([Chat]) -> Void
    //    ) -> (any ListenerRegistration)? {
    //
    //        fb.database.collection("users")
    //            .document(userID)
    //            .getDocument {
    //                documentSnapshot, error in
    //                if let error = error {
    //                    print(error.localizedDescription)
    //                    return
    //                }
    //
    //                guard let document = documentSnapshot, document.exists else {
    //                    print("user does not exist")
    //                    return
    //                }
    //                guard let appUser = try? document.data(as: AppUser.self) else {
    //                    print("Failed to decode AppUser")
    //                    return
    //                }
    //                fb.database.collection("chats").addSnapshotListener {
    //                    querySnapshot, error in
    //                    if let error = error {
    //                        print(error.localizedDescription)
    //                        return
    //                    }
    //                    guard let documents = querySnapshot?.documents else {
    //                        return
    //                    }
    //
    //                    let chats = documents.compactMap { snapshot in
    //                        return try? snapshot.data(as: Chat.self)
    //                    }.filter { chat in
    //                        return appUser.chatIDs.contains(chat.id)
    //                    }
    //                    onSuccess(chats)
    //                }
    //
    //            }
    //    }

    //        guard let userID = fb.userID else {return}
    //
    //        fb.database.collection("users").document(userID).getDocument { documentSnapshot, error in
    //                if let error = error {
    //                    print(error.localizedDescription)
    //                    return
    //                }
    //
    //                guard let document = documentSnapshot, document.exists else {
    //                    print("User document does not exist")
    //                    return
    //                }
    //
    //                // Versuche den AppUser zu decodieren
    //                guard let appUser = try? document.data(as: AppUser.self) else {
    //                    print("Failed to decode AppUser")
    //                    return
    //                }
    //
    //                // Erstelle den SnapshotListener für die Chats
    //                fb.database.collection("chats").addSnapshotListener { querySnapshot, error in
    //                    if let error = error {
    //                        print(error.localizedDescription)
    //                        return
    //                    }
    //
    //                    guard let documents = querySnapshot?.documents else { return }
    //
    //                    // Erhalte die Liste der Chats und filtere sie basierend auf den chatIDs des AppUser
    //                    let chats = documents.compactMap { snapshot in
    //                        return try? snapshot.data(as: Chat.self)
    //                    }.filter { chat in
    //                        return appUser.chatIDs.contains(chat.id ?? "")
    //                    }
    //
    //                    // Rufe den onSuccess Callback mit den gefilterten Chats auf
    //                    onSuccess(chats)
    //                }
    //            }
    //    }

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

    func loadMessages(chatID: String, onSuccess: @escaping ([Message]) -> Void)
    {
        fb.database.collection("chats")
            .document(chatID)
            .collection("messages")
            .getDocuments { snapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }

                guard let snapshot else { return }

                var messages: [Message] = []

                snapshot.documents.forEach { docSnapshot in
                    do {
                        let message = try docSnapshot.data(as: Message.self)
                        messages.append(message)
                    } catch {
                        print(error)
                    }
                }

                onSuccess(messages)
            }
    }

    func loadChats(onSuccess: @escaping ([Chat]) -> Void) {
        fb.database.collection("chats")
            .getDocuments { snapshot, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }

                guard let snapshot else { return }

                var chats: [Chat] = []

                snapshot.documents.forEach { docSnapshot in
                    do {
                        let chat = try docSnapshot.data(as: Chat.self)
                        chats.append(chat)
                    } catch {
                        print(error)
                    }
                }

                onSuccess(chats)
            }
    }

    func changeAdmin(chatID: String, newAdminID: String) {
        fb.database.collection("chats")
            .document(chatID)
            .updateData(
                ["admin": newAdminID]
            )
    }

}
