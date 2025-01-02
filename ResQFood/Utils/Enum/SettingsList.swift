//
//  SettingsList.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//

enum SettingsList : String, Identifiable, CaseIterable {
    case account = "Account"
    case about = "Über ResQFood"
    case design = "Ansicht"
    case help = "Hilfe"
    case privacy = "Privatsphäre"
    
    var id: String {
        self.rawValue
    }
}
