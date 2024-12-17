//
//  UserRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseAuth

class UserRepositoryImplementation: UserRepository {
    private let fb = FirebaseService.shared

    func logOut() {
        try? fb.auth.signOut()
    }

    func checkAuth(completion: @escaping (FirebaseAuth.User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Not logged in")
            return
        }
        completion(currentUser)
    }

    func getUser(id: String, completion: @escaping (AppUser) -> Void) {
        fb.database.collection("users").document(id).getDocument {
            snapshot, error in
            if let error {
                print(error.localizedDescription)
                return
            }

            guard let snapshot else {
                return
            }

            do {
                let user = try snapshot.data(as: AppUser.self)
                completion(user)
            } catch {
            }
        }
    }

    func createUser(
        id: String, email: String, completion: @escaping (AppUser) -> Void
    ) {
        let user = AppUser(id: id, email: email)

        do {
            try fb.database.collection("users").document(id).setData(from: user)
            completion(user)
        } catch {
            print("Saving user failed: \(error)")
        }
    }

    func createAnonymusUser(id: String, completion: @escaping (AppUser) -> Void)
    {
        let user = AppUser(id: id)

        do {
            try fb.database.collection("users").document(id).setData(from: user)
            completion(user)
        } catch {
            print("Saving user failed: \(error)")
        }
    }

    func register(
        email: String, password: String, completion: @escaping (User) -> Void,
        onFailure: @escaping () -> Void
    ) {
        fb.auth.createUser(withEmail: email, password: password) {
            authResult, error in
            if let error = error as NSError? {
                print("Login failed: \(error.localizedDescription)")
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    onFailure()
                }
                return
            } else if let error = error {
                print("Login failed: \(error.localizedDescription)")
                return
            }

            guard let authResult = authResult?.user else { return }
            completion(authResult)
        }
    }

    func loginWithEmail(
        email: String, password: String,completion: @escaping (User) -> Void, onFailure: @escaping () -> Void
    ) {
        fb.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                print("Login failed: \(error.localizedDescription)")
                if error.code == AuthErrorCode.invalidCredential.rawValue {
                    onFailure()
                }
                return
            }
            
            if let user = result?.user {
                completion(user)
            }
        }
    }

    func loginAnonymously(completion: @escaping (User) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error {
                print("SignIn failed:", error.localizedDescription)
                return
            }

            guard let authResult else { return }
            print("User is authenticated with id '\(authResult.user.uid)'")
            completion(authResult.user)
        }
    }
}
