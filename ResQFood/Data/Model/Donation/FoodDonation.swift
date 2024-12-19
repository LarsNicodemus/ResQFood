//
//  Donation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Foundation
import FirebaseFirestore

struct FoodDonation: Codable, Identifiable {
    @DocumentID var id: String?
    var creatorID: String
    var creatorName: String?
    var creationDate: Date = Date()
    var title: String
    var description: String
    var type: String
    var weight: Double
    var weightUnit: String
    var bbd: Date
    var condition: String
    var picturesUrl: [String]?
    var location: AppLocation
    var preferredTransfer: String
    var expiringDate: Date
    
    var contactInfo: ContactInfo?
    
    var chatID: String?
    var pickedUp: Bool?
    var isReserved: Bool?
}
