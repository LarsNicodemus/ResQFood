//
//  PreferredTransfer.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

enum PreferredTransfer: String, Identifiable, CaseIterable, Codable {
    case atHome = "zu Hause"
    case publicSpot = "Öffentlicher Ort"
    case other = "Sonstige"
    
    
    var id: String {
        self.rawValue
    }
}
