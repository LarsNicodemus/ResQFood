//
//  AppNavigationAnonym.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 13.12.24.
//

import SwiftUI

struct AppNavigationAnonym: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house" ){
                Text("Login Anonym")
                
            }
            Tab("Settings", systemImage: "wrench") {
                Button("Logout") {
                    authVM.logout()
                }
                .primaryButtonStyle()

                Button("Delete User") {
                    authVM.deleteUser()
                }
                .primaryButtonStyle()
            }
            
        }
    }
}

#Preview {
    AppNavigationAnonym()
        .environmentObject(AuthViewModel())
}
