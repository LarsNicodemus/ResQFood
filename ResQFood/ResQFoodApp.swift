//
//  ResQFoodApp.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI
import Firebase

@main
struct ResQFoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var imageVM = ImageViewModel()

    var body: some Scene {
        WindowGroup {
            AuthWrapper()
                .environmentObject(authVM)
                .environmentObject(profileVM)
                .environmentObject(imageVM)
        }
    }
}
