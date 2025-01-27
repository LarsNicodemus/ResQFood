//
//  AppDelegate.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 13.12.24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Diese Methode wird aufgerufen, wenn die App gestartet wird.
      /// - Parameters:
      ///   - application: Die Anwendung, die gestartet wird.
      ///   - launchOptions: Ein Dictionary mit den Startoptionen der App.
      /// - Returns: Ein Bool-Wert, der angibt, ob die App erfolgreich gestartet wurde.
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      // Konfiguriert Firebase, wenn die App gestartet wird.
      FirebaseApp.configure()

    return true
  }
}
