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
                        if let foodWasteSaved = homeVM.foodWasteforID {
                            if foodWasteSaved < 1000 {
                                Text("so viel Lebensmittelverschwendung konntest du bereits verhindern: \(String(format: "%.2f", foodWasteSaved)) g.")
                            } else {
                                Text("so viel Lebensmittelverschwendung konntest du bereits verhindern: \(String(format: "%.2f", foodWasteSaved / 1000)) Kg.")
                            }
                        }
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 32)
                
                if let totalFoodWasteSaved = homeVM.totalFoodWaste {
                    Text("so viel Lebensmittelverschwendung konnten wir zusammen bereits verhindern: \(String(format: "%.2f", (totalFoodWasteSaved / 2)/1000)) Kg.")
                    
                }
            }
            .onChange(of: profileVM.userProfile?.username) { oldValue, newValue in
                print("Username changed from \(oldValue ?? "nil") to \(newValue ?? "nil")")
                greeting = homeVM.getTimeBasedGreeting(name: newValue)
            }
            .task {
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
