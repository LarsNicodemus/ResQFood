//
//  Message.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var content: String
    var senderID: String
    var timestamp: Date = Date()
    var isread: [String: Bool] = [:]
}
