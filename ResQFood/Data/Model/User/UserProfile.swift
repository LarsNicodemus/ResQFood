//
//  UserProfile.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//
import SwiftUI

struct UserProfile: Codable {
    var id: String?
    var username: String?
    var birthDay: Date?
    var gender: String?
    var chatIDs: Set<String> = []
    var location: UserLocation?
    var pictureUrl: String?
    var rating: Double?
    var points: Int?
    var contactInfo: ContactInfo?
    var foodWasteSaved: Double?
}
