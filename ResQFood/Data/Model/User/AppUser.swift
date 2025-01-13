//
//  AppUser.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var registeredOn: Date  = Date()
    var donationIDs: Set<String> = []
    var chatIDs: Set<String> = []
    var userProfileID: String?
    }
