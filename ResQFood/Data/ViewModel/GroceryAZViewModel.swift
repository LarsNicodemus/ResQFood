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
    private var groceryRepo = GroceryAZRepositoryImplementation()
    
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

        listener = groceryRepo.addGroceryListener { groceries in
            self.groceries = groceries
        }
    }

    

//    var groceryList: [GroceryModel] = []
//
//    func addGrocery() {
//
//        Task {
//            do {
//                for grocery in groceryList {
//                    try await addG(grocery)
//                }
//                print("Erfolgreich Liste hochgeladen")
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    func addG(_ grocery: GroceryModel) async throws {
//        _ = try fb.database
//            .collection("groceryaz")
//            .addDocument(from: grocery)
//    }
}
