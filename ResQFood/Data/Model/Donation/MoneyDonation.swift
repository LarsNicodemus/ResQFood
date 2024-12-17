//
//  MoneyDonation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Foundation
import FirebaseFirestore

struct MoneyDonation: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var type: String
    var donator: String
}
