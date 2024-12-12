//
//  Chat.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//


import Foundation

struct Chat: Codable, Identifiable {
	var id: String = UUID().uuidString
	var members: Set<String>
	var admin: String
	var name: String
	var creatingDate: Date = Date()
	var lastMessage: String = ""
}
