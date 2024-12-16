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
    var bbd: Date
    var condition: String
    var pictureUrl: String?
    var location: AppLocation
    var preferredTransfer: String
    var expiringDate: Date
    var contactInfo: ContactInfo?
    var chatID: String?
    
    var donator: String
    var pickedUp: Bool?
    var isReserved: Bool?
}
