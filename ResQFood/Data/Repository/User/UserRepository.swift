//
//  UserRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseAuth

protocol UserRepository {

    func getUser(id: String, completion: @escaping (AppUser) -> Void)
    func createUser(id: String, email: String, completion: @escaping (AppUser) -> Void)
    func createAnonymusUser(id: String, completion: @escaping (AppUser) -> Void)
    func register(email: String, password: String, completion: @escaping (User) -> Void)
    func loginWithEmail(email: String, password: String)
    func loginAnonymously(completion: @escaping (User) -> Void)
    func logOut()
    func checkAuth(completion: @escaping (User) -> Void)
}
