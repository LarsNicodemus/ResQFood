//
//  AppUser.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import Foundation

struct AppUser: Codable {
    var id: String = UUID().uuidString
    var email: String
    var username: String = ""
    var joinDate: Date = Date()
    var chatIDs: Set<String> = []
}
