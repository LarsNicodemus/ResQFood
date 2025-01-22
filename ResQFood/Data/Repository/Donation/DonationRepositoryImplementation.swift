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
    
    func fetchUserIdByDonationID(_ id: String) async throws -> String {
        let reservedSnapshot = try await fb.database.collection("users")
            .whereField("reservedDonationIDs", arrayContains: id)
            .getDocuments()
        
        let collectedSnapshot = try await fb.database.collection("users")
            .whereField("collectedDonationIDs", arrayContains: id)
            .getDocuments()
        let documents = reservedSnapshot.documents + collectedSnapshot.documents
        guard let document = documents.first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Keine User-ID für diese Donation-ID gefunden"])
        }

        return document.documentID
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
    
    func updateUserDonations(userID: String, username: String?, contactInfo: ContactInfo?) async throws {
        let donations = try await fb.database
            .collection("donations")
            .whereField("creatorID", isEqualTo: userID)
            .getDocuments()
            .documents
        
        for donation in donations {
            var updates: [String: Any] = [:]
            
            if let username = username {
                updates["creatorName"] = username
            }
            
            if let contactInfo = contactInfo {
                var contactData: [String: String] = [:]
                if let email = contactInfo.email {
                    contactData["email"] = email
                }
                if let number = contactInfo.number {
                    contactData["number"] = number
                }
                if !contactData.isEmpty {
                    updates["contactInfo"] = contactData
                }
            }
            
            if !updates.isEmpty {
                try await fb.database
                    .collection("donations")
                    .document(donation.documentID)
                    .updateData(updates)
            }
        }
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
    
    func addDonationsListenerForUser(userID: String, onChange: @escaping ([FoodDonation]) -> Void) -> any ListenerRegistration {
        return fb.database
            .collection("donations")
            .whereField("creatorID", isEqualTo: userID)
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
    
    func addReservedDonationsListener(forUserID userID: String, onChange: @escaping ([FoodDonation]) -> Void) -> any ListenerRegistration {
        return fb.database
            .collection("users")
            .document(userID)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot,
                      let reservedIDs = document.data()?["reservedDonationIDs"] as? [String] else {
                    onChange([])
                    return
                }
                
                guard !reservedIDs.isEmpty else {
                    onChange([])
                    return
                }
                
                self.fb.database
                    .collection("donations")
                    .whereField(FieldPath.documentID(), in: reservedIDs)
                    .getDocuments { (donationSnapshot, error) in
                        guard let donationDocuments = donationSnapshot?.documents else {
                            onChange([])
                            return
                        }
                        
                        do {
                            let donations = try donationDocuments.compactMap { snapshot in
                                try snapshot.data(as: FoodDonation.self)
                            }
                            onChange(donations)
                        } catch {
                            print("Error decoding donations: \(error)")
                            onChange([])
                        }
                    }
            }
    }
    
    
}
