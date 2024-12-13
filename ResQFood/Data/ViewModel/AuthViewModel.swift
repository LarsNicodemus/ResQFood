//
//  AuthViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import FirebaseAuth
import Foundation

class AuthViewModel: ObservableObject {

    @Published var appUser: AppUser?
    @Published var user: User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showLoading = false
    @Published var showRegister = false
    @Published var registrationStatus: String = ""
    @Published var loginStatus: String = ""
    @Published var logoutStatus: String = ""

    private let fb = FirebaseService.shared
    private let userRepo = UserRepositoryImplementation()
    private var listener: NSObjectProtocol?

    init() {
        checkAuth()
        listener = fb.auth.addStateDidChangeListener { auth, user in
            print("\(user?.uid ?? "NO ID")")
            self.user = user
            if let user = user {
                self.createUser(id: user.uid, email: self.email)
            } else {
                self.user = nil
                self.appUser = nil
            }
        }

    }

    var userIsLoggedIn: Bool {
        user != nil
    }
    
    var userNotAnonym: Bool {
        user?.email != nil
    }
    

    func checkAuth() {
        userRepo.checkAuth { currentUser in
            self.user = currentUser
        }
    }

    private func getUser(id: String) {
        userRepo.getUser(id: id) { user in
            self.appUser = user
        }
    }

    private func createUser(id: String, email: String) {
        userRepo.createUser(id: id, email: email) { user in
            self.getUser(id: user.id)
        }
    }

    private func createAnonymusUser(id: String) {
        userRepo.createAnonymusUser(id: id) { user in
            self.getUser(id: user.id)
        }
    }

    func register() {
        userRepo.register(email: email, password: password) { userResult in
            self.user = userResult
        }
    }

    func loginWithEmail() {
        userRepo.loginWithEmail(email: email, password: password)
    }

    func loginAnonymously() {
        userRepo.loginAnonymously { userResult in
            self.user = userResult
            self.createAnonymusUser(id: userResult.uid)
        }
    }

    func logOut() {
        userRepo.logOut()
    }

}
