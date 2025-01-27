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
    
    /// Fordert die Standortberechtigung vom Benutzer an und startet die Standortaktualisierung.
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    /// Aktualisiert die Suchergebnisse basierend auf dem Suchbegriff.
    /// - Updates: `coordinates` mit den Geokoordinaten des Suchbegriffs.
    /// - Updates: `locationsInRadius` basierend auf den neuen Koordinaten.
    /// - Prints: Fehlermeldungen, wenn die Geokodierung fehlschlägt.
    func updateSearchResults() {
        print("Location before\(String(describing: coordinates))")
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
                        updateLocationsInRadius()
                        withAnimation {
                            self.position = .region(
                                MKCoordinateRegion(
                                    center: location,
                                    latitudinalMeters: self.searchRadius * 2,
                                    longitudinalMeters: self.searchRadius * 2
                                ))
                        }
                        print("Location after\(String(describing: coordinates))")
                    }
                }
            } catch {
                print("Error updating search results: \(error)")
            }
        }
    }

    /// Setzt den Standort und startet die Standortaktualisierung neu.
    /// - Updates: `position` basierend auf den neuen Koordinaten.
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

    /// CLLocationManagerDelegate-Methode, die bei Standortaktualisierungen aufgerufen wird.
    /// - Updates: `coordinates` mit den neuen Koordinaten.
    /// - Updates: `locationsInRadius` basierend auf den neuen Koordinaten.
    nonisolated func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last?.coordinate else { return }
        
        Task { @MainActor in
            self.coordinates = location
            updateLocationsInRadius()
            withAnimation {
                self.position = .region(
                    MKCoordinateRegion(
                        center: location,
                        latitudinalMeters: self.searchRadius * 2,
                        longitudinalMeters: self.searchRadius * 2
                    ))
            }
            
        }
    }

    /// Holt die Koordinaten basierend auf dem Suchbegriff.
    /// - Updates: `coordinates` mit den Geokoordinaten des Suchbegriffs.
    /// - Updates: `locationsInRadius` basierend auf den neuen Koordinaten.
    /// - Prints: Fehlermeldungen, wenn die Geokodierung fehlschlägt.
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

    /// Aktualisiert die Liste der Standorte im Umkreis basierend auf den aktuellen Koordinaten.
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

    /// Überprüft, ob ein Standort im angegebenen Radius liegt.
    /// - Parameters:
    ///   - location: Der zu überprüfende Standort.
    ///   - center: Der Mittelpunkt des Suchradius.
    /// - Returns: Ein Bool-Wert, der angibt, ob der Standort im Radius liegt.
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

    /// Aktualisiert den Suchradius und die Liste der Standorte im Umkreis.
    /// - Parameters:
    ///   - radius: Der neue Suchradius.
    func updateSearchRadius(_ radius: Double) {
        searchRadius = radius
        updateLocationsInRadius()
    }

    /// Richtet einen Listener für Spenden ein.
    /// - Entfernt vorhandene Listener, bevor ein neuer hinzugefügt wird.
    /// - Updates: `donations` mit den abgerufenen Spenden.
    /// - Updates: `isLoading` während des Ladevorgangs.
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

    /// Holt die Geokoordinaten basierend auf einer Adresse.
    /// - Parameters:
    ///   - address: Die Adresse, für die die Koordinaten ermittelt werden sollen.
    /// - Returns: Ein optionales Tupel mit den Koordinaten (Breitengrad, Längengrad).
    /// - Prints: Fehlermeldungen, wenn die Geokodierung fehlschlägt.
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

    /// Holt die Adresse basierend auf den Geokoordinaten.
    /// - Parameters:
    ///   - latitude: Der Breitengrad.
    ///   - longitude: Der Längengrad.
    /// - Returns: Die Adresse als String.
    /// - Prints: Fehlermeldungen, wenn die Rückwärtsgeokodierung fehlschlägt.
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
