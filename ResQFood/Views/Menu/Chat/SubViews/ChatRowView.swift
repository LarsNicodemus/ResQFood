//
//  ChatRowView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

struct ChatRowView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    let chat: Chat

    var body: some View {
        NavigationLink {
            ChatDetailView(currentChatID: chat.id)
        } label: {
            ChatRowContent(chat: chat)
        }
        .badge(chatVM.unreadMessagesCounts[chat.id] ?? 0)
        .onAppear {
            chatVM.startUnreadMessagesListenerForChat(chatID: chat.id)
        }
    }
}
