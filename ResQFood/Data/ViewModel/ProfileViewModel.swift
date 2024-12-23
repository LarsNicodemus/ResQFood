//
//  ProfileViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//

import Foundation
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var pictureUrl: String? = nil
    @Published var appUser: AppUser? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var username: String = ""
    @Published var birthDay: Date = Date()
    @Published var gender: String? = nil
    @Published var selectedGender: Gender = .female
    @Published var location: Adress? = nil
    @Published var locationStreetInput: String = ""
    @Published var locationCityInput: String = ""
    @Published var rating: Double? = nil
    @Published var points: Int? = nil
    @Published var contactInfo: ContactInfo? = nil
    @Published var contactEmailInput: String = ""
    @Published var contactPhoneInput: String = ""
    @Published var foodWasteSaved: Double? = nil
    private let fb = FirebaseService.shared
    private let userRepo = UserRepositoryImplementation()
    private var listener: ListenerRegistration?
    
    init() {
        setupProfileListener()
        setEmail()
        getUserByID()
    }
    
    deinit {
            listener?.remove()
            listener = nil
        }
    
    
    private func setupProfileListener() {
        listener?.remove()
        listener = nil
        
        if let userID = fb.userID {
            listener = userRepo.addProfileListener(userID: userID) { profile in
                self.userProfile = profile
            }
        }
    }
    
    func getUserByID() {
        guard let userID = fb.userID else { return }

        Task { @MainActor in

            do {
                appUser = try await userRepo.getUserByID(userID)
            } catch {
                print("appUser not created \(error)")
            }
        }
    }
    
    func setEmail(){
        guard let user = fb.auth.currentUser else { return }
        contactEmailInput = user.email ?? ""
    }
    func addProfile(){
        guard let userID = fb.userID else { return }
        if userProfile == nil {
            
            if !username.isEmpty {
                if !locationStreetInput.isEmpty && !locationCityInput.isEmpty {
                    setLocation()
                }
                if !contactEmailInput.isEmpty && !contactPhoneInput.isEmpty {
                    setContactInfo()
                }
                
                let userProfile = UserProfile(userID: userID, username: username, birthDay: birthDay, gender: gender, location: location, pictureUrl: pictureUrl, contactInfo: contactInfo )
                
                Task {
                    do {
                        try await userRepo.addProfile(userProfile)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func skipProfile(){
        guard let userID = fb.userID else { return }
        let userProfile = UserProfile(userID: userID, username: username)
        Task {
            do {
                try await userRepo.addProfile(userProfile)
            } catch {
                print(error)
            }
        }
    }
    
    func editProfile() {
        guard let userID = fb.userID else { return }
        
        let usernameUD = username.isEmpty ? nil : username
        let birthDayUD = birthDay != Date() ? nil : birthDay
        let genderUD = ((gender?.isEmpty) != nil) ? nil : gender
        let locationUD = location != nil ? nil : location
        let pictureUrlUD = ((pictureUrl?.isEmpty) != nil) ? nil : pictureUrl
        let ratingUD = rating != nil ? nil : rating
        let pointsUD = points != nil ? nil : points
        let contactInfoUD = contactInfo != nil ? nil : contactInfo
        let foodWasteSavedUD = foodWasteSaved != nil ? nil : foodWasteSaved
        
        userRepo.editProfile(id: userID, username: usernameUD, birthday: birthDayUD, gender: genderUD, location: locationUD, pictureURL: pictureUrlUD, rating: ratingUD, points: pointsUD, contactInfo: contactInfoUD, foodwasteSaved: foodWasteSavedUD)
    }
    
    func setLocation() {
        var street: String = ""
        var number: String = ""
        var zipCode: String = ""
        var city: String = ""

        if !locationStreetInput.isEmpty {
            let sanitizedInput = locationStreetInput.trimmingCharacters(in: .whitespacesAndNewlines)
            let regexPattern = #"^(.*?[^\d])\s*(\d+.*)$"#

            do {
                let regex = try NSRegularExpression(pattern: regexPattern)
                if let match = regex.firstMatch(in: sanitizedInput, range: NSRange(location: 0, length: sanitizedInput.utf16.count)) {
                    if let streetRange = Range(match.range(at: 1), in: sanitizedInput) {
                        street = String(sanitizedInput[streetRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    if let numberRange = Range(match.range(at: 2), in: sanitizedInput) {
                        number = String(sanitizedInput[numberRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                } else {
                    print("Fehler: Die Eingabe konnte nicht geparst werden. Bitte geben Sie die Adresse im Format 'Straße Hausnummer' ein.")
                    return
                }
            } catch {
                print("Regex-Fehler: \(error.localizedDescription)")
                return
            }
        }

        if !locationCityInput.isEmpty {
            let sanitizedInput = locationCityInput.trimmingCharacters(in: .whitespacesAndNewlines)
            let regex = #"(?:(\d{5})[,\s]*([a-zA-ZäöüÄÖÜß\s\-]+)|([a-zA-ZäöüÄÖÜß\s\-]+)[,\s]*(\d{5}))"#

            if let match = sanitizedInput.range(of: regex, options: .regularExpression) {
                let matchedString = String(sanitizedInput[match])
                let components = matchedString.split(separator: " ", omittingEmptySubsequences: false)

                if components.count == 2 {
                    if components[0].allSatisfy(\.isNumber), components[0].count == 5 {
                        zipCode = String(components[0])
                        city = String(components[1])
                    } else if components[1].allSatisfy(\.isNumber), components[1].count == 5 {
                        city = String(components[0])
                        zipCode = String(components[1])
                    }
                } else {
                    print("Fehler: Keine gültige PLZ und Stadt gefunden. Bitte geben Sie die Adresse im Format 'PLZ Stadt' oder 'Stadt PLZ' ein.")
                    return
                }
            } else {
                print("Fehler: Keine gültige PLZ und Stadt gefunden. Bitte geben Sie die Adresse im Format 'PLZ Stadt' oder 'Stadt PLZ' ein.")
                return
            }
        }
        let adress = Adress(Street: street, number: number, city: city, zipCode: zipCode)
        location = adress
        print("Adresse erstellt: \(adress)")
    }
    
    func setContactInfo() {
        if isValidEmail(contactEmailInput) && isValidPhoneNumber(contactPhoneInput) {
            contactInfo = ContactInfo(email: contactEmailInput, number: contactPhoneInput)
        } else if isValidEmail(contactEmailInput) && !isValidPhoneNumber(contactPhoneInput) {
            contactInfo = ContactInfo(email: contactEmailInput)
        } else if !isValidEmail(contactEmailInput) && isValidPhoneNumber(contactPhoneInput) {
            contactInfo = ContactInfo(number: contactPhoneInput)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegEx = #"^\+?[0-9]{1,4}?[-.\s]?(\(?\d{1,4}?\)?[-.\s]?)?[\d\s.-]{5,15}$"#
        let phoneNumberPred = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberPred.evaluate(with: phoneNumber)
    }
}
