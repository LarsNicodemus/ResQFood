//
//  MessageInputItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 24.01.25.
//

import SwiftUI

struct MessageInputItem: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var currentChatID: String

    var body: some View {
        HStack {
            TextField("Nachricht...", text: $chatVM.messageInput)
                .padding(8)
                .background(Color("primaryContainer").opacity(0.1))
                .clipShape(
                    RoundedRectangle(cornerRadius: 15))
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("primaryAT"),lineWidth: 1)
                }
                .onSubmit {
                    chatVM.sendMessage(chatID: currentChatID)
                            }
            Button {
                chatVM.sendMessage(chatID: currentChatID)
            } label: {
                Image(systemName: "paperplane")
            }
            .primaryButtonStyle()
        }
        .padding(.horizontal)
    }
}
