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

    func searchRecipe(_ ingredient: String) async throws -> [Meal]? {
            let urlString = "\(baseURL)/filter.php?i=\(ingredient)"
            let response: [String: [Meal]] = try await webService.downloadData(urlString: urlString)
            return response["meals"]
        }

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
