//
//  AuthWrapper.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AuthWrapper: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        NavigationStack {
            if authVM.user != nil {
                if authVM.userNotAnonym {
                    if authVM.appUser != nil {
                        if authVM.appUser?.userProfileID != nil {
                            AppNavigation()
                        } else {
                            ProfileCreationView()

                        }
                    }
                } else {
                    AppNavigationAnonym()
                }

            } else {
                LoginView()
                    .padding()
            }
        }
        .accentColor(Color("primaryAT"))
    }
}

#Preview {
    AuthWrapper()
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())
        .environmentObject(ImageViewModel())
}
