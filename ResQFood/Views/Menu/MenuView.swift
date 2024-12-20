//
//  MenuView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State var showUser = false

    var body: some View {
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

#Preview {
    MenuView()
        .environmentObject(AuthViewModel())
}
