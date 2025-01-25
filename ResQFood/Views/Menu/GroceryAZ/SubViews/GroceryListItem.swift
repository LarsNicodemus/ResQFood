//
//  GroceryListItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct GroceryListItem: View {
    var grocery: GroceryModel
    var body: some View {
        HStack {
            Text(grocery.name)
                .padding()
                .background(Color("secondaryContainer"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("primaryAT"), lineWidth: 1)
                }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
