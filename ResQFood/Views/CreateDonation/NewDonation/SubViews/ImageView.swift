//
//  ImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct ImageView: View {
    let imageURL: String
    var body: some View {
        VStack {
                   if let url = URL(string: imageURL) {
                       AsyncImage(url: url) { image in
                           image
                               .resizable()
                               .scaledToFit()
                               .frame(maxWidth: .infinity, maxHeight: 400)
                               .cornerRadius(20)
                               .shadow(radius: 10)
                       } placeholder: {
                           ProgressView()
                       }
                   } else {
                       Text("Invalid URL")
                   }
               }
           }
       }
