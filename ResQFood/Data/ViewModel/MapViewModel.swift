//
//  MapViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//
import SwiftUI
import MapKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var searchTerm: String = ""
    @Published var position: MapCameraPosition = .automatic
    @Published var searchRadius: Double = 1000
    @Published var locationsInRadius: [Location] = []
    private var allLocations: [Location] = [
        Location(name: "1KG Reis", coordinate: CLLocationCoordinate2D(latitude: 50.383, longitude: 8.052)),
        Location(name: "3 Eier", coordinate: CLLocationCoordinate2D(latitude: 50.383, longitude: 8.051)),
        Location(name: "Kaffepads", coordinate: CLLocationCoordinate2D(latitude: 50.383, longitude: 8.053)),
        Location(name: "Sixpack Bier", coordinate: CLLocationCoordinate2D(latitude: 50.383, longitude: 8.055)),
        Location(name: "Hexenhaus Lebkuchen", coordinate: CLLocationCoordinate2D(latitude: 50.383, longitude: 8.058)),
        Location(name: "Milchflasche", coordinate: CLLocationCoordinate2D(latitude: 50.3835, longitude: 8.050))
    ]
    override init() {
        super.init()
        locationManager.delegate = self
    }
    @MainActor
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.coordinates = locations.last?.coordinate
        updateLocationsInRadius()
    }
    @MainActor
    func getCoordinates() {
        Task {
            do {
                let placeMark = try await CLGeocoder().geocodeAddressString(searchTerm).first
                coordinates = placeMark?.location?.coordinate
                updateLocationsInRadius()
            } catch {
                print(error)
            }
        }
        
    }
    
    func updateLocationsInRadius() {
            guard let currentCoordinates = coordinates else { return }
            
            locationsInRadius = allLocations.filter { location in
                isLocationInRadius(location, center: currentCoordinates)
            }
        }
    
    private func isLocationInRadius(_ location: Location, center: CLLocationCoordinate2D) -> Bool {
            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let pointLocation = CLLocation(latitude: location.coordinate.latitude,
                                         longitude: location.coordinate.longitude)
            
            return centerLocation.distance(from: pointLocation) <= searchRadius
        }
    
    func addLocation(_ location: Location) {
            allLocations.append(location)
            updateLocationsInRadius()
        }
    
    func updateSearchRadius(_ radius: Double) {
            searchRadius = radius
            updateLocationsInRadius()
        }
}
