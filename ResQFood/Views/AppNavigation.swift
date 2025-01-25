//
//  AppNavigation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var mapVM: MapViewModel

    @Binding var navigationPath: NavigationPath

    @State var showUser = false
    var body: some View {
        if authVM.userNotAnonym {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView(navigationPath: $navigationPath)
                        .onAppear {
                            print(
                                "ProfilName: \(profileVM.userProfile?.username ?? "Kein Name verfügbar")"
                            )
                        }
                }

                Tab("Donation", systemImage: "document.badge.plus") {
                    CreateView()
                }

                Tab("Donations", systemImage: "list.star") {
                    DonationsView()
                }
                Tab("Menü", systemImage: "wrench") {
                    MenuView(navigationPath: $navigationPath)
                }
                .badge(chatVM.unreadMessagesCount > 0 ? chatVM.unreadMessagesCount : 0)
            }
            
            .tint(Color("primaryAT"))

        } else {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView(navigationPath: $navigationPath)

                }

                Tab("Donations", systemImage: "list.star") {
                    DonationsView()
                }

                Tab("Menü", systemImage: "wrench") {
                    MenuView(navigationPath: $navigationPath)
                }

            }
            .tint(Color("primaryAT"))

        }
    }
}

#Preview {
    AppNavigation(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())
        .environmentObject(ImageViewModel())
        .environmentObject(ProfileViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(ChatViewModel())
        .environmentObject(MapViewModel())

}
