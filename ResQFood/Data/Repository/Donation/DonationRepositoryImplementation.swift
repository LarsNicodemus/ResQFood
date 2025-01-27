//
//  DonationRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//
import FirebaseFirestore

class DonationRepositoryImplementation: DonationRepository {
    
    
    
    private let fb = FirebaseService.shared
    
    /// Ruft alle Spenden aus der Datenbank ab
    /// - Returns: Array aller FoodDonation Objekte
    /// - Throws: Fehler bei Datenbankzugriff oder Dekodierung
    func getDonations() async throws -> [FoodDonation] {
        return try await fb.database
            .collection("donations")
            .getDocuments()
            .documents
            .compactMap{ snapshot in
                try snapshot.data(as: FoodDonation.self)
            }
    }
    
    /// Prüft ob eine Spende in der Datenbank existiert
    /// - Parameter id: ID der zu prüfenden Spende
    /// - Returns: True wenn die Spende existiert, sonst false
    func isDonationAvailable(id: String) async -> Bool {
            do {
                let documentSnapshot = try await fb.database.collection("donations").document(id).getDocument()
                return documentSnapshot.exists
            } catch {
                print("Error checking donation: \(error)")
                return false
            }
        }
    
    /// Prüft ob eine Spende bereits reserviert oder abgeholt wurde
    /// - Parameter id: ID der zu prüfenden Spende
    /// - Returns: True wenn reserviert oder abgeholt, sonst false
    func isDonationReservedOrPickedUp(id: String) async -> Bool {
        do {
            let documentSnapshot = try await fb.database.collection("donations").document(id).getDocument()
            if let data = documentSnapshot.data() {
                let isReserved = data["isReserved"] as? Bool ?? false
                let pickedUp = data["pickedUp"] as? Bool ?? false
                return isReserved || pickedUp
            } else {
                print("No data found for document ID: \(id)")
                return false
            }
        } catch {
            print("Error checking donation status: \(error)")
            return false
        }
    }
    
    /// Fügt eine neue Spende zur Datenbank hinzu und aktualisiert die User-Dokumente
    /// - Parameter donation: Die zu speichernde Spende
    /// - Throws: Fehler bei Datenbankzugriff
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
    
    /// Löscht eine Spende aus der Datenbank und entfernt die Referenz beim User
    /// - Parameter id: ID der zu löschenden Spende
    /// - Throws: Fehler bei Datenbankzugriff
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
    
    /// Ermittelt die User-ID des Erstellers einer Spende
    /// - Parameter id: ID der Spende
    /// - Returns: User-ID des Erstellers
    /// - Throws: Fehler wenn keine User-ID gefunden wird
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

    /// Aktualisiert die angegebenen Felder einer Spende
    /// - Parameters:
    ///   - id: ID der zu aktualisierenden Spende
    ///   - updates: Dictionary mit zu aktualisierenden Feldern und deren Werten
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
    
    /// Aktualisiert die Benutzerinformationen in allen Spenden eines Users
    /// - Parameters:
    ///   - userID: ID des Users
    ///   - username: Neuer Benutzername (optional)
    ///   - contactInfo: Neue Kontaktinformationen (optional)
    /// - Throws: Fehler bei Datenbankzugriff
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
    
    /// Erstellt einen Listener für alle Spenden
    /// - Parameter onChange: Closure die bei Änderungen aufgerufen wird
    /// - Returns: ListenerRegistration Objekt zum späteren Entfernen des Listeners
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
    
    /// Erstellt einen Listener für die Spenden eines bestimmten Users
    /// - Parameters:
    ///   - userID: ID des Users dessen Spenden überwacht werden sollen
    ///   - onChange: Closure die bei Änderungen aufgerufen wird
    /// - Returns: ListenerRegistration Objekt zum späteren Entfernen des Listeners
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
    
    /// Erstellt einen Listener für die reservierten Spenden eines Users
    /// - Parameters:
    ///   - userID: ID des Users dessen reservierte Spenden überwacht werden sollen
    ///   - onChange: Closure die bei Änderungen aufgerufen wird
    /// - Returns: ListenerRegistration Objekt zum späteren Entfernen des Listeners
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
