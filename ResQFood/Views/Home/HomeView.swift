//
//  HomeView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var homeVM: HomeViewModel = HomeViewModel()
    @State private var greeting: String = ""

    var body: some View {
            VStack {
                VStack {
                    if authVM.userNotAnonym {
                        Text(greeting)
                            .onAppear {
                                print("HomeView appeared: Current username = \(profileVM.userProfile?.username ?? "nil")")
                                greeting = homeVM.getTimeBasedGreeting(name: profileVM.userProfile?.username)
                                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                                    greeting = homeVM.getTimeBasedGreeting(name: profileVM.userProfile?.username)
                                }
                            }
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
            .onChange(of: profileVM.userProfile?.username) { oldValue, newValue in
                print("Username changed from \(oldValue ?? "nil") to \(newValue ?? "nil")")
                greeting = homeVM.getTimeBasedGreeting(name: newValue)
            }
            .task {
                print("HomeView task started")
                profileVM.setupProfileListener()
                greeting = homeVM.getTimeBasedGreeting(name: profileVM.userProfile?.username)
            }
        }
    }

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())
}
