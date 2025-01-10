//
//  ChatView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    @State var testChatName: String = ""
    var body: some View {
        VStack {
            if chatVM.chats.isEmpty {
                EmptyChatListPlaceholder()
                
            } else {
                List(chatVM.chats) { chat in
                    NavigationLink(chat.name) {
                        
                        ChatDetailView(currentChatID: chat.id)
                    }
                    .badge(chatVM.unreadMessagesCounts[chat.id] ?? 0)
                }
            }
        }
        .customBackButton()
        .onAppear {
            for chat in chatVM.chats {
                chatVM.startUnreadMessagesListenerForChat(chatID: chat.id)
            }
        }
        .task {
            chatVM.addChatsSnapshotListener()
        }
    }
}

#Preview {
    ChatListView()
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
}
