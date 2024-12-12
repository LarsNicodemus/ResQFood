//
//  APIKEY.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

// Code ist aus Vorlesung


var APIClientId: String {
    
    guard let filePath = Bundle.main.path(forResource: "config", ofType: "plist") else {
        return ""
    }
    
    let plist = NSDictionary(contentsOfFile: filePath)
    
    guard let clientId = plist?.object(forKey: "clientId") as? String else {
        return ""
    }
    return clientId
}

