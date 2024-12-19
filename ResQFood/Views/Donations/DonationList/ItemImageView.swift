//
//  ItemImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 19.12.24.
//
import SwiftUI

struct ItemImageView: View {
    let imageurl: String
    var body: some View {
        AsyncImage(url: URL(string: imageurl), content: { image in
            image
                .resizable()
                .frame(width: 100, height: 100)
                .scaledToFit()
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10)
                )
        }, placeholder: {
            ProgressView()
        })
            
           }
       }

#Preview {
    ItemImageView(imageurl: "https://i.imgur.com/Jh9BFv2.jpeg")
}
