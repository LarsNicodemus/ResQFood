//
//  UserLocation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

struct AppLocation: Codable, Equatable {
    var lat: Double
    var long: Double
}

extension AppLocation {
    func toDictionary() -> [String: Any] {
        return [
            "lat": lat,
            "long": long
        ]
    }
}
