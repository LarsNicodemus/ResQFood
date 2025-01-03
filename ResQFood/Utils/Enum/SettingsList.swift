//
//  SettingsList.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//
import SwiftUI

enum SettingsList : String, Identifiable, CaseIterable {
    case account = "Account"
    case about = "Über ResQFood"
    case design = "Ansicht"
    case help = "Hilfe"
    case privacy = "Privatsphäre"
    
    var id: String {
        self.rawValue
    }
    
    @ViewBuilder
    func view(navigationPath: Binding<NavigationPath>) -> some View{
            switch self {
            case .account:
                AccountView(navigationPath: navigationPath)
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
