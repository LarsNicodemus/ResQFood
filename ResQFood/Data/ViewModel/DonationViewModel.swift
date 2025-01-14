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
    @Published var uploadSuccess = false
    @Published var uploadErrorMessage: String? = nil
    @Published var uploadSuccessMessage: String? = nil
    @Published var isPresent: Bool = false

    @Published var userProfile: UserProfile? = nil

    
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    private let donationRepo = DonationRepositoryImplementation()
    private let profileRepo = UserRepositoryImplementation()

    
    
    init() {
        setupDonationsListener()
    }
    
    deinit {
            listener?.remove()
            listener = nil
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

    func editDonation(id: String, updates: [DonationField : Any]) {
        donationRepo.editDonation(
            id: id, updates: updates)
    }
    func editUserInfos(userID: String, donationID: String, to status: DonationStatus, completion: @escaping (Result<String, DonationUpdateError>) -> Void) {
        profileRepo.editUserInfos(userID: userID, donationID: donationID, to: status, completion: completion)
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
