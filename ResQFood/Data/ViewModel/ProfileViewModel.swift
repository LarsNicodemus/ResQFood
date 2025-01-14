//
//  ProfileViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//

import FirebaseFirestore
import Foundation

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
    private let donRepo = DonationRepositoryImplementation()
    private var listener: ListenerRegistration?

    init() {
        setupProfileListener()
        getUserByID()
    }

    deinit {
        listener?.remove()
        listener = nil
        deinitUserProfile()
    }

    func setupProfileListener() {
        listener?.remove()
        listener = nil
        getUserByID()
        if let userID = fb.userID {
            listener = userRepo.addProfileListener(userID: userID) { profile in
                print("Profile Listener Update: \(profile?.username ?? "nil")")
                self.userProfile = profile
            }
        }
    }
    func setupOtherProfileListener(userID: String) {
        listener?.remove()
        listener = nil
        getOtherUserByID(id: userID)

        listener = userRepo.addProfileListener(userID: userID) { profile in
            print("Profile Listener Update: \(profile?.username ?? "nil")")
            self.userProfile = profile
        }

    }

    func deinitUserProfile() {
        username = ""
        birthDay = Date()
        gender = nil
        selectedGender = .female
        location = nil
        locationStreetInput = ""
        locationCityInput = ""
        rating = nil
        points = nil
        contactInfo = nil
        contactEmailInput = ""
        contactPhoneInput = ""
        foodWasteSaved = nil
    }

    func logoutProfile() {
        listener?.remove()
        listener = nil
        appUser = nil
        userProfile = nil
        deinitUserProfile()
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
    func getOtherUserByID(id: String) {
        listener = userRepo.addProfileListener(userID: id) { profile in
            print("Profile Listener Update: \(profile?.username ?? "nil")")
            self.userProfile = profile
        }
    }

    func getUpdatedFields() -> [ProfileField: Any] {
        var updates: [ProfileField: Any] = [:]

        func updateIfChanged<T: Equatable>(
            _ key: ProfileField, newValue: T?, oldValue: T?
        ) {
            if let newValue = newValue, newValue != oldValue {
                updates[key] = newValue
            }
        }

        updateIfChanged(
            .username, newValue: username, oldValue: userProfile?.username)
        updateIfChanged(
            .birthDay, newValue: birthDay, oldValue: userProfile?.birthDay)
        updateIfChanged(
            .gender, newValue: selectedGender.rawValue,
            oldValue: userProfile?.gender)

        if !locationCityInput.isEmpty || !locationStreetInput.isEmpty {
            let currentLocation = userProfile?.location
            let currentStreet =
                "\(currentLocation?.street ?? "") \(currentLocation?.number ?? "")"
            let currentCity =
                "\(currentLocation?.zipCode ?? ""), \(currentLocation?.city ?? "")"

            if locationStreetInput != currentStreet
                || locationCityInput != currentCity
            {
                var locationData: [String: String] = [:]
                locationData["street"] = location?.street
                locationData["number"] = location?.number
                locationData["city"] = location?.city
                locationData["zipCode"] = location?.zipCode

                updates[.location] = locationData.filter { !$0.value.isEmpty }
            }
        }
        let contactChanged =
            contactEmailInput != userProfile?.contactInfo?.email
            || contactPhoneInput != userProfile?.contactInfo?.number
        if contactChanged {
            var contactData: [String: String] = [:]
            contactData["email"] = contactEmailInput
            contactData["number"] = contactPhoneInput

            updates[.contactInfo] = contactData.filter { !$0.value.isEmpty }
        }

        return updates
    }

    func setProfileInfos() {
        guard let user = fb.auth.currentUser else { return }
        contactEmailInput = user.email ?? ""
        if let username = userProfile?.username {
            self.username = username
        }
        if let birthDay = userProfile?.birthDay {
            self.birthDay = birthDay
        }
        if let gender = userProfile?.gender {
            self.selectedGender = Gender.allCases.first(where: { rawgender in
                rawgender.rawValue == gender
            })!
        }
        if let street = userProfile?.location?.street,
            let number = userProfile?.location?.number
        {
            locationStreetInput = street + " " + number
        }
        if let zipCode = userProfile?.location?.zipCode,
            let city = userProfile?.location?.city
        {
            locationCityInput = zipCode + " " + city
        }
        if let email = userProfile?.contactInfo?.email {
            contactEmailInput = email
        }
        if let phone = userProfile?.contactInfo?.number {
            contactPhoneInput = phone
        }
    }

    func addProfile() {
        guard let userID = fb.userID else { return }
        if userProfile == nil {

            if !username.isEmpty {
                if !locationStreetInput.isEmpty && !locationCityInput.isEmpty {
                    setLocation()
                }
                if !contactEmailInput.isEmpty && !contactPhoneInput.isEmpty {
                    setContactInfo()
                }

                let userProfile = UserProfile(
                    userID: userID, username: username, birthDay: birthDay,
                    gender: gender, location: location, pictureUrl: pictureUrl,
                    contactInfo: contactInfo)

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

    func skipProfile() {
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

    func editProfile(updates: [ProfileField: Any]) {
        guard let userID = fb.userID else { return }
        userRepo.editProfile(id: userID, updates: updates)
        Task {
            do {
                try await donRepo.updateUserDonations(
                    userID: userID,
                    username: username.isEmpty ? nil : username,
                    contactInfo: contactInfo
                )
            } catch {
                print("Error updating donations: \(error)")
            }
        }
    }

    func setLocation() {
        var street: String = ""
        var number: String = ""
        var zipCode: String = ""
        var city: String = ""

        if !locationStreetInput.isEmpty {
            let sanitizedInput = locationStreetInput.trimmingCharacters(
                in: .whitespacesAndNewlines)
            let regexPattern = #"^(.*?[^\d])\s*(\d+.*)$"#

            do {
                let regex = try NSRegularExpression(pattern: regexPattern)
                if let match = regex.firstMatch(
                    in: sanitizedInput,
                    range: NSRange(
                        location: 0, length: sanitizedInput.utf16.count))
                {
                    if let streetRange = Range(
                        match.range(at: 1), in: sanitizedInput)
                    {
                        street = String(sanitizedInput[streetRange])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    if let numberRange = Range(
                        match.range(at: 2), in: sanitizedInput)
                    {
                        number = String(sanitizedInput[numberRange])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                } else {
                    print(
                        "Fehler: Die Eingabe konnte nicht geparst werden. Bitte geben Sie die Adresse im Format 'Straße Hausnummer' ein."
                    )
                    return
                }
            } catch {
                print("Regex-Fehler: \(error.localizedDescription)")
                return
            }
        }

        if !locationCityInput.isEmpty {
            let sanitizedInput = locationCityInput.trimmingCharacters(
                in: .whitespacesAndNewlines)
            let regex =
                #"(?:(\d{5})[,\s]*([a-zA-ZäöüÄÖÜß\s\-]+)|([a-zA-ZäöüÄÖÜß\s\-]+)[,\s]*(\d{5}))"#

            if let match = sanitizedInput.range(
                of: regex, options: .regularExpression)
            {
                let matchedString = String(sanitizedInput[match])
                let components = matchedString.split(
                    separator: " ", omittingEmptySubsequences: false)

                if components.count == 2 {
                    if components[0].allSatisfy(\.isNumber),
                        components[0].count == 5
                    {
                        zipCode = String(components[0])
                        city = String(components[1])
                    } else if components[1].allSatisfy(\.isNumber),
                        components[1].count == 5
                    {
                        city = String(components[0])
                        zipCode = String(components[1])
                    }
                } else {
                    print(
                        "Fehler: Keine gültige PLZ und Stadt gefunden. Bitte geben Sie die Adresse im Format 'PLZ Stadt' oder 'Stadt PLZ' ein."
                    )
                    return
                }
            } else {
                print(
                    "Fehler: Keine gültige PLZ und Stadt gefunden. Bitte geben Sie die Adresse im Format 'PLZ Stadt' oder 'Stadt PLZ' ein."
                )
                return
            }
        }
        let adress = Adress(
            street: street, number: number, city: city, zipCode: zipCode)
        location = adress
        print("Adresse erstellt: \(adress)")
    }

    func setContactInfo() {
        if isValidEmail(contactEmailInput)
            && isValidPhoneNumber(contactPhoneInput)
        {
            contactInfo = ContactInfo(
                email: contactEmailInput, number: contactPhoneInput)
        } else if isValidEmail(contactEmailInput)
            && !isValidPhoneNumber(contactPhoneInput)
        {
            contactInfo = ContactInfo(email: contactEmailInput)
        } else if !isValidEmail(contactEmailInput)
            && isValidPhoneNumber(contactPhoneInput)
        {
            contactInfo = ContactInfo(number: contactPhoneInput)
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegEx =
            #"^\+?[0-9]{1,4}?[-.\s]?(\(?\d{1,4}?\)?[-.\s]?)?[\d\s.-]{5,15}$"#
        let phoneNumberPred = NSPredicate(
            format: "SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberPred.evaluate(with: phoneNumber)
    }
}
