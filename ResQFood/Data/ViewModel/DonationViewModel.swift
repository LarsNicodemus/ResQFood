//
//  DonationViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import Firebase
import Foundation

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

    private let fb = FirebaseService.shared

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

    func checkForDonationUpload() {
            checkTitle()
            checkDescription()
            checkWeight()
            checkPictures()
            checkLocation()
        if titleError != nil { print(titleError!)}
            if descriptionError != nil { print(descriptionError!) }
            if weightError != nil { print(weightError!) }
            if picturesError != nil { print(picturesError!) }
            if locationError != nil { print(locationError!) }

            let allValid = titleError == nil &&
                           descriptionError == nil &&
                           weightError == nil &&
                           picturesError == nil &&
                           locationError == nil

            if allValid {
                print("Registrierung erfolgreich!!")
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

}
