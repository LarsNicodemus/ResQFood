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

    /// Erstellt einen Listener für den gesamten eingespartem Lebensmittelabfall aller Benutzer
    /// - Parameter completion: Callback mit der Gesamtsumme des eingespartem Lebensmittelabfalls oder nil
    /// - Returns: ListenerRegistration zum späteren Entfernen des Listeners
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
    
    /// Erstellt einen Listener für den eingespartem Lebensmittelabfall eines bestimmten Benutzers
    /// - Parameters:
    ///   - userID: ID des Benutzers
    ///   - completion: Callback mit der Menge des eingespartem Lebensmittelabfalls oder nil
    /// - Returns: ListenerRegistration zum späteren Entfernen des Listeners
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
