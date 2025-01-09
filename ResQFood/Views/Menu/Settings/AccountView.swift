//
//  AccountView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath

    @State var showUser = false

    var body: some View {
                VStack{
                    Button("Logout") {
                        navigationPath = NavigationPath()
                        authVM.logout()
                        profileVM.logoutProfile()
                    }
                    .primaryButtonStyle()
        
                    Button("Delete User") {
                        navigationPath = NavigationPath()
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
                }        .customBackButton()

    }
}

#Preview {
    AccountView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())

}
