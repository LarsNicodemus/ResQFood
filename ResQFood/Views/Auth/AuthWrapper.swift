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
            if authVM.user != nil {
                if authVM.appUser != nil {
                    if authVM.appUser?.userProfileID != nil || !authVM.userNotAnonym {
                        AppNavigation(navigationPath: $navigationPath)
                            .environmentObject(donVM)
                            .navigationDestination(for: NavigationRoute.self) { route in
                                switch route {
                                case .settings:
                                    SettingsOverView(navigationPath: $navigationPath)
                                case .account:
                                    AccountView(navigationPath: $navigationPath)
                                case .profil:
                                    ProfileOverView()
                                case .rewards:
                                    RewardsView()
                                case .chat:
                                    ChatListView()
                                case .community:
                                    CommunityView()
                                case .groceryAZ:
                                    GroceryAZView()
                                case .recipes:
                                    RecipesView()
                                case .partners:
                                    PartnersView()
                                case .about:
                                    AboutResQFoodView()
                                case .design:
                                    DesignView()
                                case .help:
                                    HelpAndSettingsView()
                                case .privacy:
                                    PrivacyPolicyView()
                                }
                            }
                            .onAppear {
                                chatVM.unreadMessagesBadgeListener()
                            }
                            
                    } else {
                        ProfileCreationView()
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
