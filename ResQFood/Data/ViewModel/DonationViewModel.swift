//
//  DonationViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Firebase
import FirebaseAuth
import Foundation

@MainActor
class DonationViewModel: ObservableObject {

    @Published var donations: [FoodDonation]? = nil
    

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedType: GroceryType = .fruits
    @Published var weight: Double = 0.0
    @Published var weightInputText: String = ""
    @Published var selectedWeightUnit: WeightUnit = .milligram
    @Published var bbd: Date = Date()
    @Published var selectedItemCondition: ItemCondition = .fresh
    @Published var pictureUrl: String? = nil
    @Published var picturesUrl: [String] = []
    @Published var location: AppLocation = AppLocation(lat: 0.0, long: 0.0)
    @Published var selectedPreferredTransfer: PreferredTransfer = .atHome
    @Published var expiringDate: Date = Date()
    @Published var isReserved = false
    @Published var pickedUp = false
    @Published var didValidate = false
    @Published var titleCheck = false
    @Published var descriptionCheck = false
    @Published var weightCheck = false
    @Published var picturesCheck = false
    @Published var locationCheck = false
    @Published var titleError: String? = nil
    @Published var descriptionError: String? = nil
    @Published var weightError: String? = nil
    @Published var picturesError: String? = nil
    @Published var locationError: String? = nil
    @Published var showToast: Bool = false
    @Published var showToastPickedUp: Bool = false
    @Published var uploadSuccess = false
    @Published var uploadErrorMessage: String? = nil
    @Published var uploadSuccessMessage: String? = nil
    @Published var isPresent: Bool = false
    @Published var donUserNames: [String: String] = [:]
    @Published var userProfile: UserProfile? = nil

    
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    private var listenerOtherUser: ListenerRegistration?
    private let donationRepo = DonationRepositoryImplementation()
    private let profileRepo = UserRepositoryImplementation()
    private var memberListener: ListenerRegistration?

    
    
    init() {
        setupDonationsListener()
    }
    
    deinit {
            listener?.remove()
            listener = nil
            memberListener?.remove()
            memberListener = nil
            listenerOtherUser?.remove()
            listenerOtherUser = nil
        }
    
    private func getUserProfileByID(userID: String) {
            Task {
                do {
                    userProfile = try await profileRepo.getUProfileByID(userID)
                } catch {
                    print("appUser not created \(error)")
                }
            }
    }
    
    func getUserProfileByIDwithReturn(userID: String, completion: @escaping (UserProfile?) -> Void) {
        Task {
            do {
                let profile = try await profileRepo.getUProfileByID(userID)
                await MainActor.run {
                    completion(profile)
                }
            } catch {
                print("appUser not created \(error)")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }
    func getOtherUserByIDList(donID: String, id: String) {
        memberListener = profileRepo.addProfileListener(userID: id) { profile in
            print("Member Listener Update: \(profile?.username ?? "nil")")
            self.donUserNames[donID] = profile?.username
            
        }
    }
    
    func getUserIdByDonationID(_ id: String) async throws -> String {
        return try await donationRepo.fetchUserIdByDonationID(id)
    }
    
    private func setupDonationsListener() {
        listener?.remove()
        listener = nil

        listener = donationRepo.addDonationsListener { donations in
                self.donations = donations
            }
    }
    
    func setupDonationsListenerForUser() {
        listener?.remove()
        listener = nil
        guard let userID = fb.userID else { return }

        listener = donationRepo.addDonationsListenerForUser(userID: userID ) { donations in
                self.donations = donations
            }
    }
    func setupDonationsListenerForOtherUser(userID: String) {
        listenerOtherUser?.remove()
        listenerOtherUser = nil

        listenerOtherUser = donationRepo.addDonationsListenerForUser(userID: userID ) { donations in
                self.donations = donations
            }
    }
    
    func getUserProfileByDonation(_ donID: String) {
        Task {
            do {
                let userID = try await getUserIdByDonationID(donID)
                getUserProfileByID(userID: userID)
            } catch {
                print("Fehler beim Abrufen des UserProfiles: \(error.localizedDescription)")
            }
        }
    }
    
    func addDonation() {
        guard let userID = fb.userID else { return }
        getUserProfileByID(userID: userID)
        guard let userProfile = userProfile else { return }
        guard !title.isEmpty, !description.isEmpty, weight != 0.0 else {
            return
        }
        let donation = FoodDonation(
            creatorID: userID,
            creatorName: userProfile.username,
            title: title, description: description, type: selectedType.rawValue,
            weight: weight,
            weightUnit: selectedWeightUnit.rawValue, bbd: bbd,
            condition: selectedItemCondition.rawValue,
            picturesUrl: picturesUrl,
            location: location,
            preferredTransfer: selectedPreferredTransfer.rawValue,
            expiringDate: expiringDate)
        Task {
            do {
                try await donationRepo.addDonation(donation)
                resetDonationFields()
            } catch {
                print(error)
            }
        }
    }
    func handlePickedUpAction(donation: FoodDonation) async {
        let newValue = (donation.pickedUp ?? false) == true ? false : true
        editDonation(id: donation.id!, updates: [.pickedUp: newValue])
        
        if donation.isReserved == true {
            editDonation(id: donation.id!, updates: [.isReserved: false])
        }
        
        do {
            let userID = try await getUserIdByDonationID(donation.id!)
            let status: DonationStatus = newValue ? .collected : .available
            editUserInfos(userID: userID, donationID: donation.id!, to: status) { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print(error.message)
                }
            }
        } catch {
            print("Fehler beim Abrufen der UserID: \(error.localizedDescription)")
        }
    }
    
    func handleReservedAction(donation: FoodDonation) {
        let newValue = (donation.isReserved ?? false) == true ? false : true
        editDonation(id: donation.id!, updates: [.isReserved: newValue])
    }
    
    func editDonation(id: String, updates: [DonationField : Any]) {
        donationRepo.editDonation(
            id: id, updates: updates)
    }
    func editUserInfos(userID: String, donationID: String, to status: DonationStatus, completion: @escaping (Result<String, DonationUpdateError>) -> Void) {
        profileRepo.editUserInfos(userID: userID, donationID: donationID, to: status, completion: completion)
    }
    
    func setUserPoints(otherUserID: String) {
        guard let userID = fb.userID else { return }
        
        profileRepo.updateUserPoints(userID: userID, additionalPoints: 10) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der eigenen Punkte: \(error)")
            } else {
                print("Eigene Punkte erfolgreich aktualisiert.")
            }
        }
        
        profileRepo.updateUserPoints(userID: otherUserID, additionalPoints: 5) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der Punkte des anderen Benutzers: \(error)")
            } else {
                print("Punkte des anderen Benutzers erfolgreich aktualisiert.")
            }
        }
    }
    func convertToGrams(weight: Double, unit: WeightUnit) -> Double {
        return weight * unit.toGramsConversionFactor()
    }
    
    func checkAndConvertWeightToGrams(donation: FoodDonation) -> Double {
        guard let weightUnit = WeightUnit(rawValue: donation.weightUnit) else {
            print("Unbekannte Einheit, Rückgabe des ursprünglichen Gewichts.")
            return donation.weight
        }
        
        if weightUnit != .gram {
            return convertToGrams(weight: donation.weight, unit: weightUnit)
        } else {
            return donation.weight
        }
    }

    func setFoodWasteSaved(otherUserID: String, foodWasteGramm: Double) {
        guard let userID = fb.userID else { return }
        
        profileRepo.updateFoodWasteSaved(userID: userID, foodWasteGramm: foodWasteGramm) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der eigenen Punkte: \(error)")
            } else {
                print("Eigene Punkte erfolgreich aktualisiert.")
            }
        }
        
        profileRepo.updateFoodWasteSaved(userID: otherUserID, foodWasteGramm: foodWasteGramm) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der Punkte des anderen Benutzers: \(error)")
            } else {
                print("Punkte des anderen Benutzers erfolgreich aktualisiert.")
            }
        }
    }
    
    func deleteDonation(id: String) {
        Task {
            do {
                try await donationRepo.deleteDonation(id)
            } catch {
                print(error)
            }
        }

    }

    func getDonations() {
        Task {
            do {
                donations = try await donationRepo.getDonations()
            } catch {
                print(error)
            }
        }
    }

    func convertWeight(_ input: String) -> Double {
        let cleanedInput = input.replacingOccurrences(of: ",", with: ".")
        let filteredInput = cleanedInput.filter { $0.isNumber || $0 == "." }
        if let actualInput = Double(filteredInput) {
            let roundedValue = (actualInput * 100).rounded() / 100
            return roundedValue
        } else {
            return 0.0
        }
    }

    func checkForDonationUpload() -> Bool {
        checkTitle()
        checkDescription()
        checkWeight()
        checkPictures()
        checkLocation()
        if titleError != nil { print(titleError!) }
        if descriptionError != nil { print(descriptionError!) }
        if weightError != nil { print(weightError!) }
        if picturesError != nil { print(picturesError!) }
        if locationError != nil { print(locationError!) }

        let allValid =
            titleError == nil && descriptionError == nil && weightError == nil
            && picturesError == nil && locationError == nil

        if allValid {
            addDonation()
            return true
        } else {
            print("FEHLER!!")
            return false
        }
    }

    func checkTitle() {
        if title.isEmpty {
            titleError = "Bitte geben Sie einen Titel ein."
        } else {
            titleError = nil
        }
    }
    func checkDescription() {
        if description.isEmpty {
            descriptionError = "Bitte geben Sie einen Beschreibung ein."
        } else {
            descriptionError = nil
        }
    }
    func checkWeight() {
        if weight <= 0.0 {
            weightError = "Bitte geben Sie das Gewicht an."
        } else {
            weightError = nil
        }
    }
    func checkPictures() {
        if picturesUrl.isEmpty {
            picturesError = "Bitte laden Sie min. ein Foto hoch."
        } else {
            picturesError = nil
        }
    }
    func checkLocation() {
        if location.lat == 0.0
            && location.long == 0.0
        {
            locationError = "Bitte geben Sie einen Abholadresse ein."
        } else {
            locationError = nil
        }

    }

    func resetDonationFields() {
        title = ""
        description = ""
        selectedType = .fruits
        weight = 0
        selectedWeightUnit = .milligram
        bbd = Date()
        selectedItemCondition = .fresh
        picturesUrl = []
        location = AppLocation(lat: 0.0, long: 0.0)
        selectedPreferredTransfer = .atHome
        expiringDate = Date()

    }
}
