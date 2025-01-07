//
//  HomeViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 07.01.25.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    
    func getTimeBasedGreeting(name: String?) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if name == nil {
            switch hour {
            case 5..<12:
                return "Guten Morgen"
            case 12..<17:
                return "Guten Tag"
            case 17..<21:
                return "Guten Abend"
            default:
                return "Gute Nacht"
            }
        } else {
            switch hour {
            case 5..<12:
                return "Guten Morgen, \(name!)"
            case 12..<17:
                return "Guten Tag, \(name!)"
            case 17..<21:
                return "Guten Abend, \(name!)"
            default:
                return "Gute Nacht, \(name!)"
            }
        }
        
    }
}
