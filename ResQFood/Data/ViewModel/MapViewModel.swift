//
//  MapViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//
import SwiftUI
import MapKit
import FirebaseFirestore

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var searchTerm: String = ""
    @Published var position: MapCameraPosition = .automatic
    @Published var searchRadius: Double = 1000
    @Published var locationsInRadius: [FoodDonation] = []
    @Published var donations: [FoodDonation]? = nil
    

    private var listener: ListenerRegistration?
    private let donationRepo = DonationRepositoryImplementation()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        setupDonationsListener()
    }
    
    deinit {
        listener?.remove()
        listener = nil
    }
    
    @MainActor
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func resetLocation() {
        locationManager.stopUpdatingLocation()
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
        
        locationsInRadius = donations?.filter { donation in
            isLocationInRadius(donation.location, center: currentCoordinates)
        } ?? []
    }
    
    private func isLocationInRadius(_ location: AppLocation, center: CLLocationCoordinate2D) -> Bool {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let pointLocation = CLLocation(latitude: location.lat,
                                       longitude: location.long)
        
        return centerLocation.distance(from: pointLocation) <= searchRadius
    }
    
    
    func updateSearchRadius(_ radius: Double) {
        searchRadius = radius
        updateLocationsInRadius()
    }
    
    func setupDonationsListener() {
        listener?.remove()
        listener = nil

        listener = donationRepo.addDonationsListener { donations in
                self.donations = donations
            }
    }
    
}
