//
//  MessageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 23.01.25.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @Binding var showToast: Bool
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
                        sendMessage()
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
                sendMessage()
            } label: {
                Image(systemName: "paperplane")
                Text("Nachricht senden")
            }
            .primaryButtonStyle()
            .padding(.bottom)
            .padding(.bottom)
        }
    }
    private func sendMessage(){
        if !chatVM.messageInput.isEmpty {
            
            chatVM.createChat(
                name: donation.title,
                userID: donation.creatorID,
                donationID: donation.id)
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2
            ) {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}
