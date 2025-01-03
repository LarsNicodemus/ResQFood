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
            if !mealVM.mealDetail && isFocused {
                ScrollView {
                    LazyVStack {
                        ForEach(mealVM.meals, id: \.idMeal) { meal in
                            HStack {
                                AsyncImage(url: URL(string: meal.strMealThumb))
                                { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text(meal.strMeal)
                                    .padding()
                                    .background(Color("primaryContainer"))
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 10))
                                Spacer()
                            }
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
                    ScrollView{
                        VStack(alignment: .leading) {
                            HStack{
                                AsyncImage(url: URL(string: recipe.strMealThumb))
                                { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.bottom, 16)
                                Text(recipe.strMeal)
                                    .font(.system(size: 20, weight: .bold))
                            .padding(.bottom, 4)
                            VStack{
                                HStack{
                                    Text("Herkunft: ")
                                    Text(recipe.strArea)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                HStack{
                                    Text("Kategorie: ")
                                    Text(recipe.strCategory)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                            .padding(.bottom, 16)

                            Text("Zutaten:")
                                .font(.system(size: 16, weight: .semibold))
                            VStack(alignment: .leading){
                                ForEach(recipe.ingredientsWithMeasures, id: \.ingredient) { ingredient, measure in
                                    HStack{
                                        Text(ingredient)
                                        Text(measure)
                                    }
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                }
                            }
                            .padding(.bottom, 16)
                            Text("Zubereitung:")
                                .font(.system(size: 16, weight: .semibold))
                            Text(recipe.strInstructions)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                            
                            
                            
                        }
                        .padding()
                        .padding(.bottom, 16)
                        .background(Color("primaryContainer"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
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
        .padding()
        .padding(.top, 72)
        Spacer()
    }
}

#Preview {
    RecipesView()
}
