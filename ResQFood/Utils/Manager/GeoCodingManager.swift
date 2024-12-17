//
//  GeoCodingManager.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//
import SwiftUI
import CoreLocation

class GeocodingManager: ObservableObject {
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var errorMessage: String?
    
    private let geocoder = CLGeocoder()
    
    static let shared = GeocodingManager()
    
    func fetchCoordinates(for address: String) {
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error while Geocoding: \(error.localizedDescription)"
                }
                return
            }
            
            guard let location = placemarks?.first?.location else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No matching coordinates for this adress."
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.latitude = location.coordinate.latitude
                self?.longitude = location.coordinate.longitude
                self?.errorMessage = nil
            }
        }
    }
}
