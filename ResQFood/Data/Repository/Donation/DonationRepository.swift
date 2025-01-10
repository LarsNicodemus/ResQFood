//
//  DonationRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//

import FirebaseAuth
import FirebaseFirestore

protocol DonationRepository {
    func getDonations() async throws -> [FoodDonation]
    func addDonation(_ donation: FoodDonation) async throws
    func deleteDonation(_ id: String) async throws
    func editDonation(id: String, updates: [DonationField: Any])
    func addDonationsListener(onChange: @escaping([FoodDonation]) -> Void) -> any ListenerRegistration
    func updateUserDonations(userID: String, username: String?, contactInfo: ContactInfo?) async throws

}
