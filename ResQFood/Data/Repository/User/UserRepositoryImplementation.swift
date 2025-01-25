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

    func getUserByID(_ id: String) async throws -> AppUser {
        return try await fb.database
            .collection("users")
            .document(id)
            .getDocument(as: AppUser.self)
    }

    func login(email: String, password: String) async throws {
        try await fb.auth.signIn(withEmail: email, password: password)
    }

    func loginAnonymously() async throws {
        let result = try await fb.auth.signInAnonymously()
        let user = AppUser()
        try fb.database
            .collection("users")
            .document(result.user.uid)
            .setData(from: user)
    }
    
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

    func register(email: String, password: String) async throws {
        let result = try await fb.auth.createUser(
            withEmail: email, password: password)

        let user = AppUser()
        try fb.database
            .collection("users")
            .document(result.user.uid)
            .setData(from: user)
    }

    func logout() throws {
        try? fb.auth.signOut()
    }

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

    func getUProfileByID(_ id: String) async throws -> UserProfile {
        return try await fb.database
            .collection("profiles")
            .document(id)
            .getDocument(as: UserProfile.self)
    }

}
