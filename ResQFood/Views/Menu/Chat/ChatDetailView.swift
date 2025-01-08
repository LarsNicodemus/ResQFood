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
            MessageItem(content: message.content, fromSelf: fromSelf, timestamp: message.timestamp)
                .rotationEffect(Angle(degrees: -180))
            
        }.listStyle(.plain)
            .rotationEffect(Angle(degrees: 180))
            .task {
                for message in chatVM.messages {
                    let fromSelf = message.senderID == chatVM.currentUserID

                    if !fromSelf {
                        chatVM.markMessageAsRead(chatID: currentChatID, messageID: message.id!)
                    }
                }
                
            }
        HStack{
            TextField("Nachricht...", text: $chatVM.messageInput)
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

#Preview {
    ChatDetailView(currentChatID: "51456C01-3EAB-4CF7-A639-F2F48E38A041")
        .environmentObject(ChatViewModel())

}
