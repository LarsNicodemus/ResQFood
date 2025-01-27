//
//  RewardViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.01.25.
//

import SwiftUI

class RewardViewModel: ObservableObject {
    
    private let fb = FirebaseService.shared
    private let profileRepo = UserRepositoryImplementation()

    let rewardsData = [
        Reward(lowerBound: 100, upperBound: 500, rewards: [
            RewardItem(points: 100, description: "5 % Rabatt bei einem lokalen Partner-Café"),
            RewardItem(points: 250, description: "Dankeschön-Badge in der App"),
            RewardItem(points: 500, description: "Exklusiver Rezeptzugang für kreative Resteverwertung")
        ]),
        Reward(lowerBound: 500, upperBound: 1000, rewards: [
            RewardItem(points: 600, description: "10 % Rabatt auf nachhaltige Produkte"),
            RewardItem(points: 750, description: "1 Spendenlos für die Tafel"),
            RewardItem(points: 1000, description: "Zugang zu einem Webinar zum Thema nachhaltige Ernährung")
        ]),
        Reward(lowerBound: 1000, upperBound: 1500, rewards: [
            RewardItem(points: 1100, description: "15 % Rabatt auf den nächsten Einkauf"),
            RewardItem(points: 1250, description: "Personalisierter Stoffbeutel mit App-Logo"),
            RewardItem(points: 1500, description: "2 Spendenlose für die Tafel")
        ]),
        Reward(lowerBound: 1500, upperBound: 2000, rewards: [
            RewardItem(points: 1600, description: "20 % Rabatt bei einem Partnerrestaurant"),
            RewardItem(points: 1750, description: "Einladung zu einem exklusiven Event zum Thema Zero Waste"),
            RewardItem(points: 2000, description: "3 Spendenlose für die Tafel")
        ]),
        Reward(lowerBound: 2000, upperBound: 2500, rewards: [
            RewardItem(points: 2100, description: "25 % Rabatt auf nachhaltige Haushaltsprodukte"),
            RewardItem(points: 2250, description: "Personalisierte Trinkflasche mit App-Logo"),
            RewardItem(points: 2500, description: "5 Spendenlose für die Tafel")
        ]),
        Reward(lowerBound: 2500, upperBound: 3000, rewards: [
            RewardItem(points: 2600, description: "30 % Rabatt bei einem Premium-Partner"),
            RewardItem(points: 2750, description: "VIP-Badge in der App, inklusive Zugang zu besonderen Funktionen"),
            RewardItem(points: 3000, description: "Großes Spendenlos-Paket für die Tafel")
        ])
    ]
    
    /// Überprüft, ob die Benutzerpunkte im Bereich des Rewards liegen.
    /// - Parameters:
    ///   - userPoints: Die Punkte des Benutzers.
    ///   - reward: Der Reward, der überprüft werden soll.
    /// - Returns: Ein Bool-Wert, der angibt, ob die Benutzerpunkte im Bereich des Rewards liegen.
    func isUserInRange(_ userPoints: Int, for reward: Reward) -> Bool {
            return userPoints >= reward.lowerBound
        }

    /// Überprüft, ob die Benutzerpunkte im spezifischen Bereich des Rewards liegen.
    /// - Parameters:
    ///   - userPoints: Die Punkte des Benutzers.
    ///   - reward: Der Reward, der überprüft werden soll.
    /// - Returns: Ein Bool-Wert, der angibt, ob die Benutzerpunkte im spezifischen Bereich des Rewards liegen.
        func isUserInSpecificRange(_ userPoints: Int, for reward: Reward) -> Bool {
            return userPoints >= reward.lowerBound && userPoints <= reward.upperBound
        }

    /// Überprüft, ob der Benutzer für einen bestimmten Reward berechtigt ist.
    /// - Parameters:
    ///   - userPoints: Die Punkte des Benutzers.
    ///   - rewardItem: Der RewardItem, der überprüft werden soll.
    /// - Returns: Ein Bool-Wert, der angibt, ob der Benutzer für den Reward berechtigt ist.
        func isUserEligibleForReward(_ userPoints: Int, rewardItem: RewardItem) -> Bool {
            return userPoints >= rewardItem.points
        }
    
    /// Setzt die Punkte des Benutzers und aktualisiert das Profil.
    /// - Parameters:
    ///   - points: Die neuen Punkte des Benutzers.
    /// - Prints: Erfolgs- oder Fehlermeldungen während der Aktualisierung.
    func setUserPoints(points: Int) {
        guard let userID = fb.userID else { return }
        
        profileRepo.updateUserPointsDown(userID: userID, subtractPoints: points) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der eigenen Punkte: \(error)")
            } else {
                print("Eigene Punkte erfolgreich aktualisiert.")
            }
        }
    }
}
