//
//  ChatRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseFirestore

protocol ChatRepository {
    func createChat(name: String, userID: String, content: String, donationID: String?)
    func removeUserFromChat(chatID: String, userID: String)
    func sendMessage(chatID: String, content: String)
    func userChatsListener(userID: String, completion: @escaping ([Chat]) -> Void) -> ListenerRegistration
    func chatListener(chatIDs: [String], completion: @escaping ([Chat]) -> Void)
    func addMessageSnapshotListener(chatID: String, onSuccess: @escaping ([Message]) -> Void) -> ListenerRegistration?
    func markMessageAsRead(chatID: String, messageID: String)
}
