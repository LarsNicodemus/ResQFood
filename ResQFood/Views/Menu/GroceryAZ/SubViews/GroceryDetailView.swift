//
//  GroceryDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct GroceryDetailView: View {
    var grocery: GroceryModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("Haltbarkeitstipps für \(grocery.name)")
                .font(.system(size: 18, weight: .bold))
            Text("Haltbarkeit:")
                .padding(.top, 4)
                .fontWeight(.semibold)
            Text(grocery.shelflife)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            Text("Lagerung:")
                .padding(.top, 4)
                .fontWeight(.semibold)
            Text(grocery.storage)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            Text("Verwendung:")
                .padding(.top, 4)
                .fontWeight(.semibold)
            Text(grocery.usage)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            Text("Resteverwertung:")
                .fontWeight(.semibold)
                .padding(.top, 4)
            Text(grocery.wastereduction)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .padding(.top)
        .background(Color("primaryContainer").opacity(0.2))
        .clipShape(
            RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("primaryAT"),lineWidth: 1)
        }
    }
}

//#Preview {
//    GroceryDetailView()
//}
