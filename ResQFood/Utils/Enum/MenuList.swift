//
//  MenuList.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//
import SwiftUI

enum MenuList : String, Identifiable, CaseIterable {
    case profil = "Profil"
    case rewards = "Rewards"
    case chat = "Chat"
    case community = "Community"
    case groceryAZ = "Lebensmittel A-Z"
    case recipes = "Rezepte"
    case settings = "Einstellungen"
    case partners = "Partner"
    
    var id: String {
        self.rawValue
    }
    
    @ViewBuilder
    func view(navigationPath: Binding<NavigationPath>) -> some View {
            switch self {
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
            case .settings:
                SettingsOverView(navigationPath: navigationPath)
            case .partners:
                PartnersView()
            }
        }
}
