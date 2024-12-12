//
//  APIError.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

enum HTTPError: Error {
    case invalidURL, fetchFailed, networkError
    
    var message: String {
        switch self {
        case .invalidURL: "Die URL ist ungültig"
        case .fetchFailed: "Laden ist fehlgeschlagen"
        case .networkError: "Netzwerkfehler"
        }
    }
}
