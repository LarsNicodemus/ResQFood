//
//  Donation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Foundation

struct FoodDonation: Codable, Identifiable {
    var id: String = UUID().uuidString
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
    
    var donatorId: String
    var contactInfo: ContactInfo?
    
    var chatID: String?
    var pickedUp: Bool?
    var isReserved: Bool?
}
