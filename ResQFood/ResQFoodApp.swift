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
    @StateObject private var donVM = DonationViewModel()
    @StateObject var chatVM: ChatViewModel = ChatViewModel()
    @StateObject var mapVM: MapViewModel = MapViewModel()

    var body: some Scene {
        WindowGroup {
            AuthWrapper()
                .environmentObject(authVM)
                .environmentObject(profileVM)
                .environmentObject(imageVM)
                .environmentObject(donVM)
                .environmentObject(chatVM)
                .environmentObject(mapVM)
            

        }
    }
}

