//
//  ImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct ImageView: View {
    let image: Image
    var body: some View {
        image
            .resizable()
            .frame(maxWidth: 200, maxHeight: 200)
            .scaledToFit()
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10)
            )
           }
       }
