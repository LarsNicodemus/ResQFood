//
//  AppUser.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI
import FirebaseAuth

struct AppUser: Codable, Identifiable {
    var id: String = UUID().uuidString
    
    var email: String?
    var password: String?
    var registeredOn: Date = Date()
    
}
