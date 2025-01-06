//
//  ChatView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @State var testChatName: String = ""
    var body: some View {
        VStack {
            if chatVM.chats.isEmpty {
                EmptyChatListPlaceholder()
                
            } else {
                List(chatVM.chats) { chat in
                    NavigationLink(chat.name) {
                        
                        ChatDetailView(currentChatID: chat.id)
                            .task {
                                chatVM.addMessageSnapshotListener(chatID: chat.id)
                            }
                    }
                }
            }
            Text("TestChat generieren")
            HStack{
                TextField("ChatName...", text: $testChatName)
                Button("+") {
                    chatVM.createChat(name: testChatName)
                    testChatName = ""
                }
                .primaryButtonStyle()
            }
        }.task {
            chatVM.addChatsSnapshotListener()
        }
    }
}

#Preview {
    ChatListView()
        .environmentObject(ChatViewModel())
}
