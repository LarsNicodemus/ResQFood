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
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var mapVM: MapViewModel

    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if authVM.isLoading {                
                ZStack {
                    RotatingImageView()
                        .opacity(0.8)
                    VStack {
                        Text("Bitte warten...")
                            .font(.headline)
                            .foregroundColor(Color("surface"))
                            .padding(.bottom, 10)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("surface")))
                            .scaleEffect(1.2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("surface").opacity(0.8))
                .edgesIgnoringSafeArea(.all)
                
                    } else if authVM.user != nil {
                if authVM.appUser != nil {
                    if authVM.appUser?.userProfileID != nil || !authVM.userNotAnonym {
                        AppNavigation(navigationPath: $navigationPath)
                            .environmentObject(donVM)
                            .navigationDestination(for: NavigationRoute.self) { route in
                                SwitchRoute(route: route, navigationPath: $navigationPath)
                            }
                            .onAppear {
                                chatVM.addChatsSnapshotListener()

                                chatVM.unreadMessagesBadgeListener()
                            }
                            
                    } else {
                        ProfileCreationView()
                            .padding()
                    }
                }
                    
            } else {
                LoginView()
                    .padding()
            }
        }
        .task {
            NotificationService().requestAuthorization()
        }
        .preferredColorScheme(authVM.isDarkMode ? .dark : .light)
        .accentColor(Color("primaryAT"))
    }
}


#Preview {
    AuthWrapper()
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())
        .environmentObject(ImageViewModel())
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(MapViewModel())
}
