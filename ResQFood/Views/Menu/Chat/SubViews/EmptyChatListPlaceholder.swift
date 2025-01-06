//
//  EmptyChatListPlaceholder.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 06.01.25.
//

import SwiftUI

struct EmptyChatListPlaceholder: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("PlaceholderChat")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .foregroundColor(.gray)
            
            Text("Aktuell keine Chats vorhanden.")
                .font(.title)
                .foregroundColor(.gray)
                .multilineTextAlignment(TextAlignment.center)
            
            Text("Wenn du Spendenanfragen erstellst, erscheinen diese im Chat.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(TextAlignment.center)

        }
        .padding()
    }
}

#Preview {
    EmptyChatListPlaceholder()
}
