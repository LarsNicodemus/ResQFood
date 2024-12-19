//
//  EmptyListPlaceholder.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 19.12.24.
//
import SwiftUI


struct EmptyListPlaceholder: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("placeholderIG")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.gray)
            
            Text("Keine Spenden verfügbar.")
                .font(.title)
                .foregroundColor(.gray)
            
            Text("versuch vielleicht einen anderen Radius oder andere Filter.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
