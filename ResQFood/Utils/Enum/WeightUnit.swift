//
//  WeightUnit.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

enum WeightUnit: String, Identifiable, CaseIterable, Codable {
    case milligram = "Milligramm"
    case gram = "Gramm"
    case kilogram = "Kilogramm"
    case milliliter = "Milliliter"
    case liter = "Liter"
    
    
    var id: String {
        self.rawValue
    }
}
