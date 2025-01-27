//
//  RecipeDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct RecipeDetailView: View {
    var recipe: DetailedMeal
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                HStack{
                    AsyncImage(url: URL(string: recipe.strMealThumb))
                    { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .scaledToFit()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity)
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
            .background(Color("primaryContainer").opacity(0.2))
            .clipShape(
                RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("primaryAT"),lineWidth: 1)
            }
        }
        .scrollIndicators(.hidden)
    }
}

