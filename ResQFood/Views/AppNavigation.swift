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
    @EnvironmentObject var imageVM: ImageViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

    @State var showUser = false
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house" ){
                Text("Login mit Userdaten")
                
            }
            Tab("Donation", systemImage: "document.badge.plus" ){
                CreateView()
                    .environmentObject(donVM)
                    .environmentObject(locVM)
            }
            
            Tab("Settings", systemImage: "wrench") {
                VStack{
                    Button("Logout") {
                        authVM.logout()
                    }
                    .primaryButtonStyle()
                    
                    Button("Delete User") {
                        authVM.deleteUser()
                    }
                    .primaryButtonStyle()
                    Button("Show User"){
                        showUser.toggle()
                    }
                    .primaryButtonStyle()
                    
                    if showUser {
                        if showUser {
                            if let profileID = authVM.appUser?.userProfileID, !profileID.isEmpty {
                                Text("Profile ID: \(profileID)")
                            } else {
                                Text("No valid Profile ID")
                            }
                        }
                    }
                }
            }
            
        }
    }
}

#Preview {
    AppNavigation()
        .environmentObject(AuthViewModel())
        .environmentObject(ImageViewModel())
        .environmentObject(ProfileViewModel())
}

