//
//  AuthViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

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
                if let errorMessage = try await userRepo.login(email: email, password: password) {
                    if errorMessage.contains("Passwort") {
                        passwordError = errorMessage
                    } else {
                        emailError = errorMessage
                    }
                    emailPasswordError = true
                } else {
                    resetEmailPassword()
                }
            } catch {
                print(error)
                errorMessage = "Ein unerwarteter Fehler ist aufgetreten"
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
            emailError = "E-Mail darf nicht leer sein."
        } else if !isValidEmail(email) {
            emailError = "Bitte geben Sie eine gültige E-Mail-Adresse ein."
        } else if emailPasswordError {
            emailError = emailError
        } else {
            emailError = nil
        }
    }

    func validatePassword() {
        if password.isEmpty {
            passwordError = "Passwort darf nicht leer sein."
        } else if password.count < 6 {
            passwordError = "Das Passwort muss mindestens 6 Zeichen lang sein."
        } else if emailPasswordError {
            passwordError = passwordError
        } else {
            passwordError = nil
        }
    }
    
    func validateFieldsLogin() {
       didValidate = true
       emailPasswordError = false
       isResetEmailSent = false

       validateEmail()
       validatePassword()

       if emailError == nil && passwordError == nil {
           Task {
               do {
                   if let errorMessage = try await userRepo.login(email: email, password: password) {
                       print("VIEWMODEL FEHLER: \(errorMessage)")

                       if errorMessage.contains("Passwort") {
                           
                           passwordError = "E-Mail oder Passwort fehlerhaft."
                       } else {
                           emailError = "E-Mail oder Passwort fehlerhaft."
                       }
                       emailPasswordError = true
                   } else {
                       resetEmailPassword()
                   }
               } catch let error as NSError {
                   handleFirebaseLoginError(error)
               }
           }
       }
    }
    
    private func handleFirebaseLoginError(_ error: NSError) {
        if error.domain == AuthErrorDomain {
            switch AuthErrorCode(rawValue: error.code) {
            case .wrongPassword:
                emailPasswordError = true
                passwordError = "Falsches Passwort."
                validatePassword()
            case .userNotFound:
                emailPasswordError = true
                emailError = "Benutzer nicht gefunden."
                validateEmail()
            case .invalidEmail:
                emailPasswordError = true
                emailError = "Ungültige E-Mail-Adresse."
                validateEmail()
            default:
                errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Ein Fehler ist aufgetreten: \(error.localizedDescription)"
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
