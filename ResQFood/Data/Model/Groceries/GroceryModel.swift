//
//  GroceryModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//
import Foundation
import FirebaseFirestore

struct GroceryModel: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var storage: String
    var shelflife: String
    var usage: String
    var wastereduction: String
}

