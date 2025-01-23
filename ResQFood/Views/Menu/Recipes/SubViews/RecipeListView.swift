//
//  RecipeListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct RecipeListView: View {
    var meal: Meal
    var body: some View {
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
                .background(Color("primaryContainer").opacity(0.2))
                .clipShape(
                    RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("primaryAT"),lineWidth: 1)
                }
            Spacer()
        }
    }
}

#Preview {
    RecipeListView(meal: Meal(strMeal: "Chicken & mushroom Hotpot", strMealThumb: "https://www.themealdb.com/images/media/meals/uuuspp1511297945.jpg", idMeal: "52846"))
}
