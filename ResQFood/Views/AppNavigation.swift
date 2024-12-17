//
//  AppNavigation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house" ){
                Text("Login mit Userdaten")
                Text("Login mit Userdaten")
                Text("Login mit Userdaten")
                Text("Login mit Userdaten")
            }
            Tab("Donation", systemImage: "document.badge.plus" ){
                CreateView()
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

