//
//  MoneyDonation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Foundation

struct MoneyDonation: Codable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var type: String
    var donator: String
}
