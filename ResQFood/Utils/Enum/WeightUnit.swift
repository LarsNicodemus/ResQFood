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
    
    func toGramsConversionFactor() -> Double {
            switch self {
            case .milligram:
                return 0.001
            case .gram:
                return 1.0
            case .kilogram:
                return 1000.0
            case .milliliter:
                return 1.0
            case .liter:
                return 1000.0 
            }
        }
}
