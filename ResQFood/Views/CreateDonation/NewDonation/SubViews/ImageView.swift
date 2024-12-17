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
            .frame(width: 200, height: 200)
            .scaledToFit()
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10)
            )
           }
       }
