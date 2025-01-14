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
    
    func editUserInfos(userID: String, donationID: String, to status: DonationStatus, completion: @escaping (Result<String, DonationUpdateError>) -> Void) {
        
        fb.database.collection("users").document(userID).getDocument { [self] document, error in
            guard let document = document,
                  var user = try? document.data(as: AppUser.self) else {
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
                if user.collectedDonationIDs.contains(donationID) {
                    completion(.failure(.alreadyCollected))
                    return
                }
                user.reservedDonationIDs.remove(donationID)
                user.collectedDonationIDs.insert(donationID)
            }
            
            do {
                try self.fb.database.collection("users").document(userID).setData(from: user)
                completion(.success("Update erfolgreich"))
            } catch {
                completion(.failure(.unknown))
            }
        }
    }

    func addProfileListener(userID: String, onChange: @escaping (UserProfile?) -> Void) -> any ListenerRegistration {
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
    
    func addUserListener(userID: String, completion: @escaping (AppUser?) -> Void) -> ListenerRegistration {
        return fb.database
            .collection("users")
            .document(userID)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
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
