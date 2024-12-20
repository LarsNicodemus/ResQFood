//
//  TabModelEnum.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//


import SwiftUI

enum TabModel: String, CaseIterable {
    case home = "fridgeicon"
    case create = "giveicon"
    case donations = "receiveicon"
    case menu = "menuicon"
    
    
    var title: String {
        switch self {
        case .home:  "Home"
        case .create: "Erstellen"
        case .donations:  "Spenden"
        case .menu:  "Menü"
        }
    }
    
    var navigateTo: AnyView {
        switch self {
        case .home: return AnyView(HomeView())
        case .create: return AnyView(CreateView())
        case .donations: return AnyView(DonationsView())
        case .menu: return AnyView(MenuView())
        }
    }
}
