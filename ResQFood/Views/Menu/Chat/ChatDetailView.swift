//
//  ChatDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var currentChatID: String
    var body: some View {
        List(chatVM.messages) { message in
            let fromSelf = message.senderID == chatVM.currentUserID
            MessageItem(content: message.content, fromSelf: fromSelf)
                .rotationEffect(Angle(degrees: -180))
            
        }.listStyle(.plain)
            .rotationEffect(Angle(degrees: 180))
        HStack{
            TextField("Nachricht...", text: $chatVM.messageInput)
            Button {
                chatVM.sendMessage(chatID: currentChatID)
            } label: {
                Image(systemName: "paperplane")
            }
            .primaryButtonStyle()
        }
    }
}

#Preview {
    ChatDetailView(currentChatID: "1")
        .environmentObject(ChatViewModel())

}
