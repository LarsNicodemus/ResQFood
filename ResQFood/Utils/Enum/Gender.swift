//
//  Gender.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

enum Gender: String, Identifiable, CaseIterable {
    case male = "Mann"
    case female = "Frau"
    case diverse = "Divers"
    
    var id: String {
        self.rawValue
    }
}
