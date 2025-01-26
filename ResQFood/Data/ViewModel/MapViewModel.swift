import FirebaseFirestore
import MapKit
//
//  MapViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//
import SwiftUI

@MainActor
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    private var locationManager = CLLocationManager()

    @Published var coordinates: CLLocationCoordinate2D?
    @Published var searchTerm: String = ""
    @Published var position: MapCameraPosition = .automatic
    @Published var searchRadius: Double = 1000
    @Published var locationsInRadius: [FoodDonation] = []
    @Published var donations: [FoodDonation]? = nil
    @Published var startPressed: Bool = false
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedItems: Set<GroceryType> = []
    @Published var filerToggle: Bool = false
    @Published var isLoading: Bool = true

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

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func updateSearchResults() {
        guard !searchTerm.isEmpty else {
            locationsInRadius = []
            return
        }

        Task {
            do {
                if let placeMark = try await CLGeocoder().geocodeAddressString(
                    searchTerm
                ).first,
                    let location = placeMark.location?.coordinate
                {
                    await MainActor.run {
                        self.coordinates = location
                        withAnimation {
                            self.position = .region(
                                MKCoordinateRegion(
                                    center: location,
                                    latitudinalMeters: self.searchRadius * 2,
                                    longitudinalMeters: self.searchRadius * 2
                                ))
                        }
                        updateLocationsInRadius()
                    }
                }
            } catch {
                print("Error updating search results: \(error)")
            }
        }
    }

    func resetLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()

        if let coordinates = coordinates {
            withAnimation {
                position = .region(
                    MKCoordinateRegion(
                        center: coordinates,
                        latitudinalMeters: searchRadius * 2,
                        longitudinalMeters: searchRadius * 2
                    ))
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last?.coordinate else { return }

        Task { @MainActor in
            self.coordinates = location

            withAnimation {
                self.position = .region(
                    MKCoordinateRegion(
                        center: location,
                        latitudinalMeters: self.searchRadius * 2,
                        longitudinalMeters: self.searchRadius * 2
                    ))
            }
            updateLocationsInRadius()
        }
    }

    func getCoordinates() {
        Task {
            do {
                let placeMark = try await CLGeocoder().geocodeAddressString(
                    searchTerm
                ).first
                coordinates = placeMark?.location?.coordinate
                updateLocationsInRadius()
            } catch {
                print(error)
            }
        }

    }

    func updateLocationsInRadius() {
        guard let currentCoordinates = coordinates else {
            return
        }

        locationsInRadius =
            donations?.filter { donation in
                isLocationInRadius(
                    donation.location, center: currentCoordinates)
            } ?? []
    }

    private func isLocationInRadius(
        _ location: AppLocation, center: CLLocationCoordinate2D
    ) -> Bool {
        let centerLocation = CLLocation(
            latitude: center.latitude, longitude: center.longitude)
        let pointLocation = CLLocation(
            latitude: location.lat,
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

        isLoading = true
        listener = donationRepo.addDonationsListener { donations in
            DispatchQueue.main.async {
                self.donations = donations
                self.isLoading = false

                self.updateLocationsInRadius()

            }
        }
    }

    func getCoordinatesFromAddress(_ address: String) async -> (
        latitude: Double, longitude: Double
    )? {
        do {
            if let placeMark = try await CLGeocoder().geocodeAddressString(
                address
            ).first,
                let location = placeMark.location?.coordinate
            {
                return (location.latitude, location.longitude)
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return nil
    }

    func getAddressFromCoordinates(latitude: Double, longitude: Double) async
        -> String
    {
        do {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(
                location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? ""
                let postalCode = placemark.postalCode ?? ""
                return "\(postalCode), \(city)".trimmingCharacters(
                    in: .whitespaces)
            }
        } catch {
            print("Reverse geocoding error: \(error)")
        }
        return "Ort nicht gefunden"
    }

}
