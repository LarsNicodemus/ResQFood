//
//  MessageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var donation: FoodDonation
    var body: some View {
        VStack {
            ZStack {
                TextEditor(text: $chatVM.messageInput)
                    .scrollContentBackground(.hidden)
                    .background(Color("secondaryContainer"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color("primaryAT"), lineWidth: 1)
                    }
                    .onSubmit {
                        chatVM.sendMessagefromDon(donation: donation)
                                }
                if chatVM.messageInput.isEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(
                                "Bitte gib hier deine Nachricht ein..."
                            )
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.leading, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.bottom, 8)
            Button {
                chatVM.sendMessagefromDon(donation: donation)
            } label: {
                Image(systemName: "paperplane")
                Text("Nachricht senden")
            }
            .primaryButtonStyle()
            .padding(.bottom)
            .padding(.bottom)
        }
    }

}
