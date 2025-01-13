//
//  Mockdata.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 10.01.25.
//
import SwiftUI

struct MockData {
    static let foodDonationMock: FoodDonation = FoodDonation(
        id: "mockID123",
        creatorID: "creator123",
        creatorName: "Max Mustermann",
        creationDate: Date(),
        title: "Fresh Apples",
        description: "A box of fresh apples, around 5kg, picked from the orchard yesterday.",
        type: "Fruit",
        weight: 5.0,
        weightUnit: "kg",
        bbd: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        condition: "Fresh",
        picturesUrl: ["https://i.imgur.com/GSzY54V.jpeg", "https://i.imgur.com/9gaakhs.jpeg"],
        location: AppLocation(
            lat: 48.1351,
            long: 11.5820
        ),
        preferredTransfer: "Pickup",
        expiringDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
        contactInfo: ContactInfo(
            email: "donator@example.com",
            number: "123456789"
        ),
        pickedUp: true,
        isReserved: true
    )
}
