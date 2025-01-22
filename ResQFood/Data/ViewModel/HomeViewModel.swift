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
    
    func setupDonationsListener() {
        reservedListener?.remove()
        reservedListener = nil
        guard let userID = fb.userID else {return}
        reservedListener = donRepo.addReservedDonationsListener(forUserID: userID, onChange: { donations in
            self.reservedDonations = donations
        })
    }

    
    func getFoodWasteCountListener() {
        listener = homeRepo.getFoodWasteCountListener(completion: { totalFoodWaste in
            self.totalFoodWaste = totalFoodWaste
        })
    }
    func getFoodWasteCountListenerForID() {
        guard let userID = fb.userID else {return}
        listenerforID = homeRepo.getFoodWasteCountListenerForID(userID: userID) { foodWaste in
            self.foodWasteforID = foodWaste
        }
    }

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
