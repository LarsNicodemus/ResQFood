//
//  AppNavigation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var donVM: DonationViewModel = DonationViewModel()
    @StateObject var locVM: LocationViewModel = LocationViewModel()
    @StateObject var imageVM: ImageViewModel = ImageViewModel()
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house" ){
                Text("Login mit Userdaten")
                
            }
            Tab("Donation", systemImage: "document.badge.plus" ){
                CreateView()
                    .environmentObject(donVM)
                    .environmentObject(locVM)
                    .environmentObject(imageVM)
            }
            Tab("Settings", systemImage: "wrench") {
                Button("Logout") {
                    authVM.logOut()
                }
            }
            
        }
    }
}

#Preview {
    AppNavigation()
        .environmentObject(AuthViewModel())
}

