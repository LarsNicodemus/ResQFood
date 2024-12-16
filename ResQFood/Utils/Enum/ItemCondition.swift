//
//  Condition.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

enum ItemCondition: String, Identifiable, CaseIterable, Codable {
    case fresh = "frisch"
    case good = "gut"
    case dents = "Dellen"
    case spots = "braune Stellen"
    case broke = "zerbrochen"
    case scratched = "Kratzer"
    case damaged = "beschädigt"
    case opened = "geöffnet"
    case sealed = "verschlossen"
    
    var id: String {
        self.rawValue
    }
}
