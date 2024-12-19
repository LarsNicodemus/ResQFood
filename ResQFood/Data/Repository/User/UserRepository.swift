//
//  UserRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseAuth
import FirebaseFirestore

protocol UserRepository {

    func getUserByID(_ id: String) async throws -> AppUser
    func login(email: String, password: String) async throws
    func loginAnonymously() async throws
    func register(email: String, password: String) async throws
    func logout() throws
    func deleteUser() async throws
    func editProfile(id: String, username: String?, birthday: Date?, gender: String?, location: Adress?, pictureURL: String?, rating: Double?, points: Int?, contactInfo: ContactInfo?, foodwasteSaved: Double?)
    func addProfile(_ profile: UserProfile) async throws
    func addUserListener(userID: String, completion: @escaping (AppUser?) -> Void) -> ListenerRegistration
    func getUProfileByID(_ id: String) async throws -> UserProfile

}
