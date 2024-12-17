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
    
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?
    
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
    
    func checkForDonationUpload() {
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
            addDonation(
                title: title, description: description,
                type: selectedType.rawValue, weight: weight,
                weightUnit: selectedWeightUnit.rawValue, bbd: bbd,
                condition: selectedItemCondition.rawValue,
                picturesUrl: picturesUrl, location: location,
                preferredTransfer: selectedPreferredTransfer.rawValue,
                expiringDate: expiringDate)
        } else {
            print("FEHLER!!")
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
    
    func addDonation(
        title: String, description: String, type: String, weight: Double,
        weightUnit: String, bbd: Date, condition: String, picturesUrl: [String]?,
        location: AppLocation,
        preferredTransfer: String, expiringDate: Date
    ) {
        guard let userId = fb.userID else {
            print("Fehler beim Laden der User ID!")
            return
        }
        
        let foodDonation = FoodDonation(
            title: title, description: description, type: type, weight: weight,
            weightUnit: weightUnit, bbd: bbd, condition: condition,
            picturesUrl: picturesUrl,
            location: location, preferredTransfer: preferredTransfer,
            expiringDate: expiringDate, donatorId: userId)
        
        do {
            let _ = try fb.database.collection("donations").addDocument(
                from: foodDonation
            ) { error in
                if let error = error {
                    self.uploadErrorMessage =
                    "Fehler beim Speichern der Donation: \(error.localizedDescription)"
                    self.uploadSuccess = false
                    print(
                        "Fehler beim Speichern der Donation: \(error.localizedDescription)"
                    )
                    print("Fehler beim Speichern der Donation!")
                } else {
                    self.uploadSuccess = true
                    self.uploadSuccessMessage = "Deine Spende wurde erfolgreich erstellt."
                    self.resetDonationFields()
                    print("Donation erfolgreich angelegt!")
                }
            }
        } catch {
            uploadErrorMessage = "Unerwarteter Fehler: \(error.localizedDescription)"
            uploadSuccess = false
            print("Unerwarteter Fehler: \(error.localizedDescription)")
            print("Fehler beim Speichern deDonation!")
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
