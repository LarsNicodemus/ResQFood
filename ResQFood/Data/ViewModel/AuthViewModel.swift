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
    @Published var isSecure = true
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var didValidate = false
    @Published var emailAlredyUsed = false
    @Published var emailPasswordError = false
    @Published var errorMessage = ""
    @Published var isResetEmailSent = false

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
        } onFailure: {
            self.emailAlredyUsed = true
        }
    }

    func loginWithEmail() {
        userRepo.loginWithEmail(email: email, password: password) {
            self.emailPasswordError = true
        }
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

    func validateEmail() {
        if email.isEmpty {
            emailError = "Email darf nicht leer sein."
        } else if !email.contains("@") {
            emailError = "Bitte geben Sie eine gültige Email-Adresse ein."
        } else if emailAlredyUsed {
            emailError = "Diese Email-Adresse wird bereits verwendet."
        } else if emailPasswordError && !isResetEmailSent {
            emailError = "Email-Adresse oder Passwort fehlerhaft."
        } else if isResetEmailSent {
            emailError = "Reset Email wurde gesendet."
        } else {
            emailError = nil
        }
    }

    func validatePassword() {
        if password.isEmpty {
            passwordError = "Passwort darf nicht leer sein."
        } else if password.count < 6 {
            passwordError = "Das Passwort muss mindestens 6 Zeichen lang sein."
        } else {
            passwordError = nil
        }
    }

    func validateFieldsLogin() {
        didValidate = true
        validateEmail()
        validatePassword()

        if emailError == nil && passwordError == nil {
            loginWithEmail()
        }
    }

    func validateFieldsRegister() {
        didValidate = true
        validateEmail()
        validatePassword()

        if emailError == nil && passwordError == nil {
            register()
        }
    }

    func sendPasswordResetEmail() {
        guard !email.isEmpty, isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        fb.auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                switch error {
                case AuthErrorCode.userNotFound:
                    self.errorMessage = "No user found with this email"
                case AuthErrorCode.invalidEmail:
                    self.errorMessage = "Invalid email format"
                case AuthErrorCode.networkError:
                    self.errorMessage =
                        "Network error. Please check your connection"
                default:
                    self.errorMessage = error.localizedDescription
                }
            } else {
                self.errorMessage = ""
                self.isResetEmailSent = true
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}
