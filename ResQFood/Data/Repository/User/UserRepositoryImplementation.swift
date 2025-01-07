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
    
    func editProfile(
        id: String, username: String?, birthday: Date?, gender: String?,
        location: Adress?, pictureURL: String?, rating: Double?, points: Int?,
        contactInfo: ContactInfo?, foodwasteSaved: Double?
    ) {
        var valuesToUpdate: [String: Any] = [:]
        if let username { valuesToUpdate["username"] = username }
        if let birthday { valuesToUpdate["birthday"] = birthday }
        if let gender { valuesToUpdate["gender"] = gender }
        if let location { valuesToUpdate["location"] = location }
        if let pictureURL { valuesToUpdate["pictureURL"] = pictureURL }
        if let rating { valuesToUpdate["rating"] = rating }
        if let points { valuesToUpdate["points"] = points }
        if let contactInfo { valuesToUpdate["contactInfo"] = contactInfo }
        if let foodwasteSaved {
            valuesToUpdate["foodwasteSaved"] = foodwasteSaved
        }
        guard !valuesToUpdate.isEmpty else { return }
        fb.database
            .collection("profiles")
            .document(id)
            .updateData(valuesToUpdate)
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
