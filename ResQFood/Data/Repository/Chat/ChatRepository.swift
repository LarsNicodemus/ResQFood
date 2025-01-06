//
//  ChatRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseFirestore

protocol ChatRepository {
    func createChat(name: String)
    func addUserToChat(chatID: String, userID: String)
    func removeUserFromChat(chatID: String, userID: String)
    func sendMessage(chatID: String, content: String)
    func userChatsListener(userID: String, completion: @escaping ([Chat]) -> Void) -> ListenerRegistration
    func chatListener(chatIDs: [String], completion: @escaping ([Chat]) -> Void)
    func addMessageSnapshotListener(chatID: String, onSuccess: @escaping ([Message]) -> Void) -> ListenerRegistration?
    func loadMessages(chatID: String, onSuccess: @escaping ([Message]) -> Void)
    func loadChats(onSuccess: @escaping ([Chat]) -> Void)
    func changeAdmin(chatID: String, newAdminID: String)
}
