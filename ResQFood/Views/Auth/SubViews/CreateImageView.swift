//
//  CreateImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 26.01.25.
//

import SwiftUI

struct CreateImageView: View {
    let image: Image
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color("primaryAT"), lineWidth: 1))
            .shadow(radius: 2)
           }
       }

