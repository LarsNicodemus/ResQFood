//
//  GroceryAZRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

protocol GroceryAZRepository {
    func addGroceryListener(onChange: @escaping ([GroceryModel]) -> Void)
        -> any ListenerRegistration
}
