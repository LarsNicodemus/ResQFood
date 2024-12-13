//
//  AuthWrapper.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AuthWrapper: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack{
            if authVM.userIsLoggedIn {
                if authVM.userNotAnonym {
                    AppNavigation()
                } else {
                    AppNavigationAnonym()
                }
                
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    AuthWrapper()
        .environmentObject(AuthViewModel())
}
