//
//  GroceryAZRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class GroceryAZRepositoryImplementation: GroceryAZRepository {
    private let fb = FirebaseService.shared

    func addGroceryListener(onChange: @escaping ([GroceryModel]) -> Void)
        -> any ListenerRegistration
    {
        return fb.database
            .collection("groceryaz")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                do {
                    let groceries = try documents.compactMap { snapshot in
                        try snapshot.data(as: GroceryModel.self)
                    }
                    onChange(groceries)
                } catch {
                    print(error)
                }
            }
    }
}
