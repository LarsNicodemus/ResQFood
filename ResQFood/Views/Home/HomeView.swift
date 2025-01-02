//
//  HomeView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack{
            VStack{
                if authVM.userNotAnonym {
                    Text("Login mit Userdaten")
                } else {
                    Text("Login Anonym")
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
