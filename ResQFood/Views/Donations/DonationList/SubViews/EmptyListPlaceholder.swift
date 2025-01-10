//
//  EmptyListPlaceholder.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 19.12.24.
//
import SwiftUI


struct EmptyListPlaceholder: View {
    var firstText: String
    var secondText: String
    var body: some View {
        VStack(spacing: 20) {
            Image("placeholderIG")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.gray)
            
            Text(firstText)
                .font(.title)
                .foregroundColor(.gray)
            
            Text(secondText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    EmptyListPlaceholder(firstText: "Keine Spenden verfügbar.", secondText: "versuch vielleicht einen anderen Radius oder andere Filter.")
}
