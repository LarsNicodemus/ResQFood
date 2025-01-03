//
//  DetailImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 03.01.25.
//

import SwiftUI

struct DetailImageView: View {
    let imageurl: String
    var body: some View {
        AsyncImage(
            url: URL(string: imageurl),
            content: { image in
                image
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .scaledToFit()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10)
                    )
            },
            placeholder: {
                ProgressView()
            })

    }
}

#Preview {
    DetailImageView(imageurl: "https://i.imgur.com/Jh9BFv2.jpeg")
}
