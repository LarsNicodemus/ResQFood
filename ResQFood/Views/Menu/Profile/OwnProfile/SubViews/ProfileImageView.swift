//
//  ProfileImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 09.01.25.
//

import SwiftUI

struct ProfileImageView: View {
    let imageurl: String?
    var body: some View {
        if let url = imageurl {
            AsyncImage(
                url: URL(string: url),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("primaryAT"), lineWidth: 1))
                        .shadow(radius: 2)
                },
                placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("primaryAT"), lineWidth: 1))
                        .shadow(radius: 2)
                })
            
            
        } else {
            Image("placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("primaryAT"), lineWidth: 1))
                .shadow(radius: 2)
        }
    }
}

#Preview {
    ProfileImageView(imageurl: "https://i.imgur.com/1ejoivh.jpeg")
}
