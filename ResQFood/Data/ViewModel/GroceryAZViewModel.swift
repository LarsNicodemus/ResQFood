//
//  GroceryAZViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class GroceryAZViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var description: String = ""
    @Published var storage: String = ""
    @Published var shelflife: String = ""
    @Published var usage: String = ""
    @Published var wastereduction: String = ""
    @Published var groceries: [GroceryModel]? = nil
    @Published var searchInput: String = ""
    @Published var groceryDetail: Bool = false
    @Published var selectedGrocery: String = ""
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?

    init() {
        setupGroceryListener()
    }
    deinit {
        listener?.remove()
        listener = nil
    }

    private func setupGroceryListener() {
        listener?.remove()
        listener = nil

        listener = addGroceryListener { groceries in
            self.groceries = groceries
        }
    }

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

    var groceryList: [GroceryModel] = []

    func addGrocery() {

        Task {
            do {
                for grocery in groceryList {
                    try await addG(grocery)
                }
                print("Erfolgreich Liste hochgeladen")
            } catch {
                print(error)
            }
        }
    }

    func addG(_ grocery: GroceryModel) async throws {
        _ = try fb.database
            .collection("groceryaz")
            .addDocument(from: grocery)
    }
}
