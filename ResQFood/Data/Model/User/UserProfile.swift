//
//  UserProfile.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//
import SwiftUI
import FirebaseFirestore

struct UserProfile: Codable {
    @DocumentID var id: String?
    var userID: String
    var username: String
    var birthDay: Date?
    var gender: String?
    var location: Adress?
    var pictureUrl: String?
    var rating: Int?
    var ratings: [Int]?
    var points: Int?
    var contactInfo: ContactInfo?
    var foodWasteSaved: Double?
    var ratedBy: Set<String> = []
}
