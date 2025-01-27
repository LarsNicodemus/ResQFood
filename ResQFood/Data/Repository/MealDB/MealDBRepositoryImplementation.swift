//
//  MealDBRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//


import SwiftUI

class MealDBRepositoryImplementation: MealDBRepository {
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    private let webService: WebService = WebService()

    /// Sucht Rezepte basierend auf einer Zutat und gibt eine Liste von Mahlzeiten zurück.
    /// - Parameters:
    ///   - ingredient: Die Zutat, nach der gesucht werden soll
    /// - Throws: Wirft einen Fehler, wenn das Herunterladen der Daten fehlschlägt
    /// - Returns: Eine optionale Liste von `Meal`-Objekten, die die gefundenen Rezepte repräsentieren
    func searchRecipe(_ ingredient: String) async throws -> [Meal]? {
            let urlString = "\(baseURL)/filter.php?i=\(ingredient)"
            let response: [String: [Meal]] = try await webService.downloadData(urlString: urlString)
            return response["meals"]
        }

    /// Ruft die Details eines Rezepts basierend auf der Rezept-ID ab und gibt die detaillierten Mahlzeiteninformationen zurück.
    /// - Parameters:
    ///   - idMeal: Die ID der Mahlzeit, deren Details abgerufen werden sollen
    /// - Throws: Wirft einen Fehler, wenn das Herunterladen der Daten fehlschlägt
    /// - Returns: Ein optionales `DetailedMeal`-Objekt, das die Details der Mahlzeit repräsentiert
    func getRecipeDetails(idMeal: String) async throws -> DetailedMeal? {
            let urlString = "\(baseURL)/lookup.php?i=\(idMeal)"
            let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
            if let rawString = String(data: data, encoding: .utf8) {
                print("Rohdaten der API-Antwort: \(rawString)")
            }
            let response: [String: [DetailedMeal]] = try await webService.downloadData(urlString: urlString)
            return response["meals"]?.first
        }
}
