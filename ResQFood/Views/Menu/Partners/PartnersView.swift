//
//  PartnersView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct PartnersView: View {
    var body: some View {
            VStack {
                ZStack {
                    Text("Dieses Feature wird")
                        .font(Fonts.title)
                        .foregroundStyle(Color("primaryAT"))
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .offset(y: 18)
                }
                ZStack {
                    Text("mit dem nächsten")
                        .font(Fonts.title)
                        .foregroundStyle(Color("primaryAT"))
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .offset(y: 18)
                }
                ZStack {
                    Text("Update implementiert.")
                        .font(Fonts.title)
                        .foregroundStyle(Color("primaryAT"))
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340)
                        .offset(y: 18)
                }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("surface"))
            .customBackButton()

    }
}

#Preview {
    PartnersView()
}
