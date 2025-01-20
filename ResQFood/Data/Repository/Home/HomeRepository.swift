//
//  HomeRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 15.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

protocol HomeRepository {
    
    func getFoodWasteCountListener(completion: @escaping (Double?) -> Void) -> ListenerRegistration 
    func getFoodWasteCountListenerForID(userID: String, completion: @escaping (Double?) -> Void) -> ListenerRegistration
    
}

