//
//  GroceryType.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//
import Foundation

enum GroceryType: String, Identifiable, CaseIterable, Codable {
    case fruits = "Früchte"
    case vegetables = "Gemüse"
    case dairy = "Milchprodukte"
    case meat = "Fleisch"
    case fish = "Fisch"
    case grains = "Getreide"
    case beverages = "Getränke"
    case snacks = "Snacks"
    case bakery = "Bäckerei"
    case frozen = "Tiefkühlprodukte"
    case condiments = "Würzmittel"
    case cannedGoods = "Dosenprodukte"
    case sweets = "Süßigkeiten"
    case cleaningSupplies = "Reinigungsmittel"
    case householdItems = "Haushaltswaren"
    case healthAndBeauty = "Gesundheit & Schönheit"
    case babyProducts = "Babyprodukte"
    case petSupplies = "Tierbedarf"
    
    var id: String {
        self.rawValue
    }
}
