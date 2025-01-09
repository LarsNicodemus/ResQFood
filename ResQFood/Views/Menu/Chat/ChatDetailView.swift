//
//  ChatDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    @State var title = "kein Titel"
    @State var creator = "kein Name"
    var currentChatID: String
    var body: some View {
        VStack {

            List(chatVM.messages) { message in
                let fromSelf = message.senderID == chatVM.currentUserID
                MessageItem(
                    content: message.content, fromSelf: fromSelf,
                    timestamp: message.timestamp
                )
                .rotationEffect(Angle(degrees: -180))
                .onAppear {
                    if !fromSelf
                        && message.isread[chatVM.currentUserID] == false
                    {
                        chatVM.markMessageAsRead(
                            chatID: currentChatID, messageID: message.id!)
                    }
                }
            }.listStyle(.plain)
                .rotationEffect(Angle(degrees: 180))

            HStack {
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundStyle(Color("tertiary"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text(creator)
                    .foregroundStyle(Color("primaryAT"))
            }
        }
        .customBackButton()

        .onAppear{
            chatVM.addMessageSnapshotListener(chatID: currentChatID)
            let chat = chatVM.chats.first { chat in
                chat.id == currentChatID
            }
            let donation = donVM.donations?.first(where: { donation in
                donation.id == chat?.donationID
            })
            if let creatorID = donation?.creatorID {
                chatVM.getOtherUserByID(id: creatorID)
            }
            if let creator = chatVM.userProfile?.username {
                self.creator = creator
            }
            if let title = donation?.title {
                self.title = title
            }
        }
        
    }
    
}

#Preview {
    ChatDetailView(currentChatID: "51456C01-3EAB-4CF7-A639-F2F48E38A041")
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())

}
