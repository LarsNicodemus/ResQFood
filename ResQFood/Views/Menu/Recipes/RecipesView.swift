//
//  RecipesView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

struct RecipesView: View {
    @StateObject var mealVM: MealDBViewModel = MealDBViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            if !mealVM.mealDetail {
                ZStack{
                    Text("Rezepte")
                        .font(Fonts.title)
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110)
                        .offset(y: 18)
                }
                Text("Hier kannst du nach einer Zutat suchen die du zu Hause hast oder in den Spenden gefunden und dich inspirieren lassen, was damit alles gekocht werden kann. es kann nach einer Zutat gesucht werden. Wenn du mehrere hast, probier es gerne nacheinander aus ;)")
                
            }
            ZStack{
                TextField("Suche: ", text: $mealVM.ingredient)
                    .focused($isFocused)
                    .onChange(of: isFocused) { oldValue, newValue in
                        if newValue {
                            mealVM.mealDetail = false
                            mealVM.ingredient = ""
                        }
                    }
                Image("Strich")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .offset(x: -35, y: 15)
            }
            Spacer()
            if !mealVM.mealDetail && isFocused {
                ScrollView {
                    VStack {
                        ForEach(mealVM.meals, id: \.idMeal) { meal in
                            RecipeListView(meal: meal)
                            .padding(.vertical, 4)
                            .onTapGesture {
                                mealVM.mealDetail = true
                                mealVM.selectedMeal = meal.idMeal
                                isFocused = false
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            else {
                if let recipe = mealVM.selectedRecipe {
                    RecipeDetailView(recipe: recipe)
                }
                
            }
        }
        .onChange(of: mealVM.ingredient) { oldValue, newValue in
            mealVM.searchRecipies()
        }
        .onChange(of: mealVM.selectedMeal) { oldValue, newValue in
            if !newValue.isEmpty {
                mealVM.getRecipeDetails()
                print(newValue)
            }
        }
        .customBackButton()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("secondaryContainer"))
    }
}

#Preview {
    RecipesView()
}
