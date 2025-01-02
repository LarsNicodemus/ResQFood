//
//  MealDBRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//

import SwiftUI

protocol MealDBRepository {
    func searchRecipe(_ ingredient: String) async throws -> [Meal]?
    func getRecipeDetails(idMeal: String) async throws -> DetailedMeal?
}
