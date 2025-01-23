//
//  ImageViewURL.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct ImageViewURL: View {
    var image: String
    var body: some View {
        if let imageURL = URL(string: image) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 200, height: 200)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10
                        )
                    )
                }
    }
}
