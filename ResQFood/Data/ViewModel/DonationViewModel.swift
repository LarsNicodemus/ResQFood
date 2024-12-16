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
}
