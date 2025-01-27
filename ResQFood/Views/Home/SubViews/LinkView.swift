//
//  LinkView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

struct LinkView: View {
    var body: some View {
        
            NavigationLink{
                GroceryAZView()
            } label: {
                ZStack {
                    HStack{
                        Text("Lebensmittel A-Z")
                            .font(Fonts.title)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .frame(width: 250, alignment: .center)
                            .foregroundStyle(Color("primaryAT"))
                        Image("arrow1")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 290, alignment: .leading)
                        .offset(y: 18)
                }
            }
            NavigationLink{
                RecipesView()
            } label: {
                ZStack {
                    HStack{
                        Text("Rezepte")
                            .font(Fonts.title)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .frame(width: 120, alignment: .center)
                            .foregroundStyle(Color("primaryAT"))
                        Image("arrow1")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, alignment: .leading)
                        .offset(y: 18)
                }
            }
    }
}
