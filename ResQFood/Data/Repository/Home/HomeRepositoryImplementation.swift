//
//  HomeRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 15.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class HomeRepositoryImplementation: HomeRepository {

    private let fb = FirebaseService.shared
    private let db = FirebaseService.shared.database

    func getFoodWasteCountListener(completion: @escaping (Double?) -> Void) -> ListenerRegistration{
        return fb.database
            .collection("profiles")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    completion(0.0)
                    return
                }
                let totalFoodWaste = documents.compactMap {
                    document -> Double? in
                    do {
                        let userProfile = try document.data(
                            as: UserProfile.self)
                        return userProfile.foodWasteSaved
                    } catch {
                        print("Error decoding document: \(error)")
                        return nil
                    }
                }.reduce(0.0, +)

                completion(totalFoodWaste)
            }
    }

    func getFoodWasteCountListenerForID(
        userID: String, completion: @escaping (Double?) -> Void) -> ListenerRegistration {
        return fb.database
            .collection("profiles")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents,
                    let document = documents.first
                else {
                    completion(nil)
                    return
                }
                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    completion(userProfile.foodWasteSaved)
                } catch {
                    print(error)
                    completion(nil)
                }
            }
    }

}
