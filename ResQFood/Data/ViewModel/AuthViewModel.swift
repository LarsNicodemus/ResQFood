//
//  AuthViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
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
    @Published var resetNavigation = false
    
    private let fb = FirebaseService.shared
    private let userRepo = UserRepositoryImplementation()
    private var listener: NSObjectProtocol?
    private var userListener: ListenerRegistration?


    init() {
        listener = fb.auth.addStateDidChangeListener { auth, user in
            self.user = user
            self.setupUserListener()
        }

    }

    deinit {
        listener = nil

        userListener?.remove()
        userListener = nil
    }

    
    private func setupUserListener() {
        userListener?.remove()
        userListener = nil
        
        if let userID = fb.userID {
            userListener = userRepo.addUserListener(userID: userID) { user in
                    self.appUser = user
            }
        }
    }
    
    func getUserByID() {
        guard let userID = fb.userID else { return }

        Task {
            do {
                appUser = try await userRepo.getUserByID(userID)
            } catch {
                print("appUser not created \(error)")
            }
        }
    }

    func login() {
        Task {
            do {
                try await userRepo.login(email: email, password: password)
                resetEmailPassword()
            } catch {
                print(error)
            }
            
        }
    }

    func loginAnonym() {
        Task {
            do {
                try await userRepo.loginAnonymously()
            } catch {
                print(error)
            }
        }
    }

    func register() {
        Task {
            do {
                try await userRepo.register(email: email, password: password)
                resetEmailPassword()
            } catch {
                print(error)
            }
        }
    }
    func reauthenticateUser(currentPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = fb.auth.currentUser, let email = user.email else {
            completion(false, "Benutzer ist nicht eingeloggt.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(false, "Re-Authentifizierung fehlgeschlagen: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) {
        reauthenticateUser(currentPassword: currentPassword) { [weak self] success, errorMessage in
            guard success else {
                DispatchQueue.main.async {
                    self?.errorMessage = errorMessage ?? "Unbekannter Fehler."
                }
                return
            }
            
            self?.fb.auth.currentUser?.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = "Fehler beim Aktualisieren des Passworts: \(error.localizedDescription)"
                    } else {
                        self?.errorMessage = "Passwort wurde erfolgreich geändert."
                    }
                }
            }
        }
    }
    
    func logout() {
            do {
                userListener?.remove()
                userListener = nil
                try userRepo.logout()
                appUser = nil
                user = nil
            } catch {
                print(error)
            }
        }
    
    func deleteUser() {
        Task {
            do {
                userListener?.remove()
                userListener = nil
                try await userRepo.deleteUser()
                appUser = nil
                user = nil
            } catch {
                print(error)
            }
        }
    }

    var userIsLoggedIn: Bool {
        user != nil
    }

    var userNotAnonym: Bool {
        user?.email != nil
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
        emailPasswordError = false
        isResetEmailSent = false
        if emailError == nil && passwordError == nil {
            login()
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
    
    func resetEmailPassword(){
        email = ""
        password = ""
    }

}
