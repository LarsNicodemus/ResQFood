//
//  Chat.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//


import Foundation
import FirebaseFirestore

struct Chat: Codable, Identifiable {
    var id: String = UUID().uuidString
	var members: Set<String>
	var admin: String
	var name: String
    var creationDate: Date = Date()
	var lastMessage: Date = Date()
}
