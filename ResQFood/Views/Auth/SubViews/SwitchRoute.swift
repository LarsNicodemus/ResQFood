//
//  SwitchRoute.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//
import SwiftUI

struct SwitchRoute: View {
    var route: NavigationRoute
    @Binding var navigationPath: NavigationPath
    var body: some View {
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
}
