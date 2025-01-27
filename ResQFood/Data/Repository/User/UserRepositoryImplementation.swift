//
//  UserRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseAuth
import FirebaseFirestore

class UserRepositoryImplementation: UserRepository {

    private let fb = FirebaseService.shared
    private let db = FirebaseService.shared.database

    // Ruft einen Benutzer anhand seiner ID aus der Datenbank ab
    /// - Parameter id: Die ID des gesuchten Benutzers
    /// - Returns: AppUser Objekt
    /// - Throws: Fehler bei Datenbankzugriff oder Dekodierung
    func getUserByID(_ id: String) async throws -> AppUser {
        return try await fb.database
            .collection("users")
            .document(id)
            .getDocument(as: AppUser.self)
    }

    /// Meldet einen Benutzer mit Email und Passwort an
    /// - Parameters:
    ///   - email: Email-Adresse des Benutzers
    ///   - password: Passwort des Benutzers
    /// - Returns: Fehlermeldung als String oder nil bei Erfolg
    /// - Throws: Auth-Fehler bei ungültigen Anmeldedaten
    func login(email: String, password: String) async throws {
        try await fb.auth.signIn(withEmail: email, password: password)
    }

    /// Erstellt einen anonymen Benutzer-Account
    /// - Throws: Fehler bei der Erstellung des Accounts
    func loginAnonymously() async throws {
        let result = try await fb.auth.signInAnonymously()
        let user = AppUser()
        try fb.database
            .collection("users")
            .document(result.user.uid)
            .setData(from: user)
    }
    
    /// Registriert einen neuen Benutzer
    /// - Parameters:
    ///   - email: Email-Adresse für den neuen Account
    ///   - password: Passwort für den neuen Account
    /// - Throws: Fehler bei der Registrierung
    func login(email: String, password: String) async throws -> String? {
       do {
           try await fb.auth.signIn(withEmail: email, password: password)
           return nil
       } catch let error as NSError {
           
           if error.domain == AuthErrorDomain {
               switch AuthErrorCode(rawValue: error.code) {
               case .wrongPassword:
                   return "Falsches Passwort"
               case .userNotFound:
                   return "Benutzer nicht gefunden"
               case .invalidEmail:
                   return "Ungültige E-Mail-Adresse"
               default:
                   return error.localizedDescription
               }
           }
           return error.localizedDescription
       }
    }

    /// Registriert einen neuen Benutzer
    func register(email: String, password: String) async throws {
        let result = try await fb.auth.createUser(
            withEmail: email, password: password)

        let user = AppUser()
        try fb.database
            .collection("users")
            .document(result.user.uid)
            .setData(from: user)
    }

    /// Meldet den aktuellen Benutzer ab
    /// - Throws: Fehler beim Abmelden
    func logout() throws {
        try? fb.auth.signOut()
    }


    /// Löscht den aktuellen Benutzer-Account inkl. aller Daten
    /// - Throws: Fehler beim Löschen
    func deleteUser() async throws {
        guard let userID = fb.userID else { return }
        try await fb.database
            .collection("users")
            .document(userID)
            .delete()
        try await fb.database
            .collection("profiles")
            .document(userID)
            .delete()
        try await fb.auth.currentUser?.delete()
    }

    /// Fügt ein neues Benutzerprofil hinzu
    /// - Parameter profile: Das zu speichernde Profil
    /// - Throws: Fehler beim Speichern
    func addProfile(_ profile: UserProfile) async throws {
        guard let userID = fb.userID else { return }

        let docRef = fb.database.collection("profiles").document(userID)
        let docSnapshot = try await docRef.getDocument()

        if !docSnapshot.exists {
            try docRef.setData(from: profile)

            try await fb.database
                .collection("users")
                .document(userID)
                .updateData([
                    "userProfileID": userID
                ])
        }
    }

    /// Aktualisiert bestimmte Felder eines Benutzerprofils
    /// - Parameters:
    ///   - id: ID des zu aktualisierenden Profils
    ///   - updates: Dictionary mit zu aktualisierenden Feldern
    func editProfile(id: String, updates: [ProfileField: Any]) {
        var valuesToUpdate: [String: Any] = [:]

        for (field, value) in updates {
            switch field {
            case .location:
                if let locationDict = value as? [String: String] {
                    valuesToUpdate[field.rawValue] = locationDict
                }
            case .contactInfo:
                if let contactDict = value as? [String: String] {
                    valuesToUpdate[field.rawValue] = contactDict
                }
            default:
                valuesToUpdate[field.rawValue] = value
            }
        }

        guard !valuesToUpdate.isEmpty else { return }

        fb.database
            .collection("profiles")
            .document(id)
            .updateData(valuesToUpdate)
    }

    /// Erhöht die Punktzahl eines Benutzers
    /// - Parameters:
    ///   - userID: ID des Benutzers
    ///   - additionalPoints: Anzahl der hinzuzufügenden Punkte
    ///   - completion: Callback mit möglichem Fehler
    func updateUserPoints(
        userID: String, additionalPoints: Int,
        completion: @escaping (Error?) -> Void
    ) {
        let profileRef = db.collection("profiles").document(userID)

        profileRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentPoints = document.data()?["points"] as? Int ?? 0
                let updatedPoints = currentPoints + additionalPoints

                profileRef.updateData(["points": updatedPoints]) { error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    /// Verringert die Punktzahl eines Benutzers
    /// - Parameters:
    ///   - userID: ID des Benutzers
    ///   - subtractPoints: Anzahl der abzuziehenden Punkte
    ///   - completion: Callback mit möglichem Fehler
    func updateUserPointsDown(
        userID: String, subtractPoints: Int,
        completion: @escaping (Error?) -> Void
    ) {
        let profileRef = db.collection("profiles").document(userID)

        profileRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentPoints = document.data()?["points"] as? Int ?? 0
                let updatedPoints = currentPoints - subtractPoints

                profileRef.updateData(["points": updatedPoints]) { error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }

    /// Aktualisiert die Menge an eingespartem Lebensmittelabfall
    /// - Parameters:
    ///   - userID: ID des Benutzers
    ///   - foodWasteGramm: Eingespartes Gewicht in Gramm
    ///   - completion: Callback mit möglichem Fehler
    func updateFoodWasteSaved(
        userID: String, foodWasteGramm: Double,
        completion: @escaping (Error?) -> Void
    ) {
        let profileRef = db.collection("profiles").document(userID)

        profileRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentWasteSaved =
                    document.data()?["foodWasteSaved"] as? Double ?? 0.0
                let updatedWasteSaved = currentWasteSaved + foodWasteGramm

                profileRef.updateData(["foodWasteSaved": updatedWasteSaved]) {
                    error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }

    /// Fügt eine neue Bewertung für einen Benutzer hinzu
    /// - Parameters:
    ///   - currenUserID: ID des bewertenden Benutzers
    ///   - userID: ID des zu bewertenden Benutzers
    ///   - rating: Bewertung (1-5)
    ///   - completion: Callback mit möglichem Fehler
    func updateRatingAndRatedBy(
        currenUserID: String, userID: String, rating: Int,
        completion: @escaping (Error?) -> Void
    ) {
        let profileRef = db.collection("profiles").document(userID)

        profileRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                completion(error)
                return
            }

            var currentRatings = document.data()?["ratings"] as? [Int] ?? []
            var currentRatedBy = document.data()?["ratedBy"] as? [String] ?? []

            if !currentRatedBy.contains(currenUserID) {
                currentRatings.append(rating)
                currentRatedBy.append(currenUserID)

                let averageRating = Int(
                    Double(currentRatings.reduce(0, +))
                        / Double(currentRatings.count))

                profileRef.updateData([
                    "ratings": currentRatings,
                    "ratedBy": currentRatedBy,
                    "rating": averageRating,
                ]) { error in
                    completion(error)
                }
            } else {
                completion(
                    NSError(
                        domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Already rated"]))
            }
        }
    }

    /// Entfernt eine Bewertung eines Benutzers
    /// - Parameters:
    ///   - currentUserID: ID des Benutzers dessen Bewertung entfernt wird
    ///   - userID: ID des bewerteten Benutzers
    ///   - completion: Callback mit möglichem Fehler
    func removeUserRating(
        currentUserID: String, userID: String,
        completion: @escaping (Error?) -> Void
    ) {
        let profileRef = db.collection("profiles").document(userID)

        profileRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                completion(error)
                return
            }

            var currentRatings = document.data()?["ratings"] as? [Int] ?? []
            var currentRatedBy = document.data()?["ratedBy"] as? [String] ?? []

            if let index = currentRatedBy.firstIndex(of: currentUserID) {
                currentRatings.remove(at: index)
                currentRatedBy.remove(at: index)

                var updateData: [String: Any] = [
                    "ratings": currentRatings,
                    "ratedBy": currentRatedBy,
                ]

                if !currentRatings.isEmpty {
                    let newRating =
                        currentRatings.reduce(0, +) / currentRatings.count
                    updateData["rating"] = newRating
                } else {
                    updateData["rating"] = FieldValue.delete()
                }

                profileRef.updateData(updateData) { error in
                    completion(error)
                }
            } else {
                completion(
                    NSError(
                        domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No rating found"]
                    ))
            }
        }
    }

    /// Aktualisiert den Status einer Spende für einen Benutzer
    /// - Parameters:
    ///   - userID: ID des Benutzers
    ///   - donationID: ID der Spende
    ///   - status: Neuer Status der Spende
    ///   - completion: Callback mit Erfolg/Fehler-Resultat
    func editUserInfos(
        userID: String, donationID: String, to status: DonationStatus,
        completion: @escaping (Result<String, DonationUpdateError>) -> Void
    ) {

        fb.database.collection("users").document(userID).getDocument {
            [self] document, error in
            guard let document = document,
                var user = try? document.data(as: AppUser.self)
            else {
                completion(.failure(.documentError))
                return
            }

            switch status {
            case .reserved:
                if user.reservedDonationIDs.contains(donationID) {
                    completion(.failure(.alreadyReserved))
                    return
                }
                if user.collectedDonationIDs.contains(donationID) {
                    completion(.failure(.alreadyCollected))
                    return
                }
                user.reservedDonationIDs.insert(donationID)

            case .collected:
                user.reservedDonationIDs.remove(donationID)
                user.collectedDonationIDs.insert(donationID)

            case .available:
                user.collectedDonationIDs.remove(donationID)
                user.reservedDonationIDs.remove(donationID)
            }

            do {
                try self.fb.database.collection("users").document(userID)
                    .setData(from: user)
                completion(.success("Update erfolgreich"))
            } catch {
                completion(.failure(.unknown))
            }
        }
    }

    /// Erstellt einen Listener für Änderungen am Benutzerprofil
    /// - Parameters:
    ///   - userID: ID des zu überwachenden Profils
    ///   - onChange: Callback der bei Änderungen aufgerufen wird
    /// - Returns: ListenerRegistration zum späteren Entfernen
    func addProfileListener(
        userID: String, onChange: @escaping (UserProfile?) -> Void
    ) -> any ListenerRegistration {
        return fb.database
            .collection("profiles")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    return
                }

                guard let document = documents.first else {
                    return
                }

                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    onChange(userProfile)
                } catch {
                    print(error)
                }
            }
    }

    /// Erstellt einen Listener für Änderungen am Benutzer
    /// - Parameters:
    ///   - userID: ID des zu überwachenden Benutzers
    ///   - completion: Callback der bei Änderungen aufgerufen wird
    /// - Returns: ListenerRegistration zum späteren Entfernen
    func addUserListener(
        userID: String, completion: @escaping (AppUser?) -> Void
    ) -> ListenerRegistration {
        return fb.database
            .collection("users")
            .document(userID)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print(
                        "Error fetching document: \(error?.localizedDescription ?? "Unknown error")"
                    )
                    completion(nil)
                    return
                }

                do {
                    let user = try document.data(as: AppUser.self)
                    completion(user)
                } catch {
                    print("Error decoding user: \(error)")
                    completion(nil)
                }
            }
    }

    /// Ruft ein Benutzerprofil anhand seiner ID ab
    /// - Parameter id: ID des gesuchten Profils
    /// - Returns: UserProfile Objekt
    /// - Throws: Fehler bei Datenbankzugriff oder Dekodierung
    func getUProfileByID(_ id: String) async throws -> UserProfile {
        return try await fb.database
            .collection("profiles")
            .document(id)
            .getDocument(as: UserProfile.self)
    }

}
