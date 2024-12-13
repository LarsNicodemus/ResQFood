//
//  FirebaseService.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private init() {}
    
    let auth = Auth.auth()
    let database = Firestore.firestore()
    
    var userID: String? {
        auth.currentUser?.uid
    }
}
