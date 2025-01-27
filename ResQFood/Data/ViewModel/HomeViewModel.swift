//
//  HomeViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 07.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var totalFoodWaste: Double? = nil
    @Published var foodWasteforID: Double? = nil
    @Published var reservedDonations: [FoodDonation]? = nil
    @Published var greeting: String = ""

    private let fb = FirebaseService.shared
    private let userRepo = UserRepositoryImplementation()
    private let donRepo = DonationRepositoryImplementation()
    private let homeRepo = HomeRepositoryImplementation()
    private var listener: ListenerRegistration?
    private var listenerforID: ListenerRegistration?
    private var reservedListener: ListenerRegistration?

    init(){
        getFoodWasteCountListener()
        getFoodWasteCountListenerForID()
        setupDonationsListener()
    }
    
    deinit{
        listener?.remove()
        listener = nil
        listenerforID?.remove()
        listenerforID = nil
        reservedListener?.remove()
        reservedListener = nil
        reservedDonations = nil
    }
    
    /// Richtet einen Listener für reservierte Spenden des Benutzers ein.
    /// - Entfernt vorhandene Listener, bevor ein neuer hinzugefügt wird.
    /// - Updates: `reservedDonations` mit den abgerufenen Spenden für den Benutzer.
    func setupDonationsListener() {
        reservedListener?.remove()
        reservedListener = nil
        guard let userID = fb.userID else {return}
        reservedListener = donRepo.addReservedDonationsListener(forUserID: userID, onChange: { donations in
            self.reservedDonations = donations
        })
    }

    /// Richtet einen Listener für die Gesamtmenge des Lebensmittelabfalls ein.
    /// - Updates: `totalFoodWaste` mit der abgerufenen Menge des Lebensmittelabfalls.
    func getFoodWasteCountListener() {
        listener = homeRepo.getFoodWasteCountListener(completion: { totalFoodWaste in
            self.totalFoodWaste = totalFoodWaste
        })
    }
    
    /// Richtet einen Listener für die Menge des Lebensmittelabfalls eines bestimmten Benutzers ein.
    /// - Updates: `foodWasteforID` mit der abgerufenen Menge des Lebensmittelabfalls für die Benutzer-ID.
    func getFoodWasteCountListenerForID() {
        guard let userID = fb.userID else {return}
        listenerforID = homeRepo.getFoodWasteCountListenerForID(userID: userID) { foodWaste in
            self.foodWasteforID = foodWaste
        }
    }
    
    /// Gibt eine zeitbasierte Begrüßung zurück.
    /// - Parameters:
    ///   - name: Der Name des Benutzers (optional).
    /// - Returns: Eine Begrüßung basierend auf der aktuellen Tageszeit und optional dem Namen des Benutzers.
    func getTimeBasedGreeting(name: String?) -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        if name == nil {
            switch hour {
            case 5..<12:
                return "Guten Morgen"
            case 12..<17:
                return "Guten Tag"
            case 17..<21:
                return "Guten Abend"
            default:
                return "Gute Nacht"
            }
        } else {
            switch hour {
            case 5..<12:
                return "Guten Morgen, \(name!)"
            case 12..<17:
                return "Guten Tag, \(name!)"
            case 17..<21:
                return "Guten Abend, \(name!)"
            default:
                return "Gute Nacht, \(name!)"
            }
        }

    }
}
