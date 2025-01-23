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
                .background(Color("primaryContainer"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
