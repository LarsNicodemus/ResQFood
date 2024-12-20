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
        if authVM.userNotAnonym {
            Text("Login mit Userdaten")
        } else {
            Text("Login Anonym")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
