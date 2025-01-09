//
//  DonationRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//
import FirebaseFirestore

class DonationRepositoryImplementation: DonationRepository {
    
    
    
    private let fb = FirebaseService.shared
    
    func getDonations() async throws -> [FoodDonation] {
        return try await fb.database
            .collection("donations")
            .getDocuments()
            .documents
            .compactMap{ snapshot in
                try snapshot.data(as: FoodDonation.self)
            }
    }
    
    func addDonation(_ donation: FoodDonation) async throws {
        guard let userID = fb.userID else { return }
        let result = try fb.database
            .collection("donations")
            .addDocument(from: donation)
        try await fb.database
            .collection("users")
            .document(userID)
            .updateData([
                "donationIDs" : FieldValue.arrayUnion([result.documentID])
            ])
    }
    
    func deleteDonation(_ id: String) async throws {
        guard let userID = fb.userID else { return }
        try await fb.database
            .collection("donations")
            .document(id)
            .delete()
        try await fb.database
            .collection("users")
            .document(userID)
            .updateData([
                "donationIDs" : FieldValue.arrayRemove([id])
            ])
    }
    


    func editDonation(id: String, updates: [DonationField: Any]) {
        var valuesToUpdate: [String: Any] = [:]
        
        for (field, value) in updates {
                valuesToUpdate[field.rawValue] = value
        }
        
        guard !valuesToUpdate.isEmpty else { return }
        
        fb.database
            .collection("donations")
            .document(id)
            .updateData(valuesToUpdate)
    }
    
    
    func addDonationsListener(onChange: @escaping ([FoodDonation]) -> Void) -> any ListenerRegistration {
        return fb.database
            .collection("donations")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                do {
                                    let donations = try documents.compactMap { snapshot in
                                        try snapshot.data(as: FoodDonation.self)
                                    }
                                    onChange(donations)
                                } catch {
                                    print(error)
                                }
            }
    }
    
}
