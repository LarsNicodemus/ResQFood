//
//  DonationUpdateError.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//

enum DonationUpdateError: Error {
    case alreadyReserved
    case alreadyCollected
    case documentError
    case unknown
    
    var message: String {
        switch self {
            case .alreadyReserved: return "Diese Spende ist bereits reserviert"
            case .alreadyCollected: return "Diese Spende wurde bereits abgeholt"
            case .documentError: return "Dokument konnte nicht geladen werden"
            case .unknown: return "Ein unbekannter Fehler ist aufgetreten"
        }
    }
}
