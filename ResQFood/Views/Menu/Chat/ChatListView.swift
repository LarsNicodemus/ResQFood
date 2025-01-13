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
                    NavigationLink {
                        
                        ChatDetailView(currentChatID: chat.id)
                    } label: {
                    
                        VStack(alignment: .leading){
                            if let username = chatVM.chatUsernames[chat.id] {
                                Text(username)
                                    .bold()
                            }
                            
                            HStack{
                                Text(chat.name)
                                Spacer()
                                Text(chat.lastMessage.formatted())
                                    .font(.system(size: 10))
                            }
                            
                        }.task{
                            if let membersID = chat.members.first(where: { id in
                                id != chatVM.currentUserID
                            }){
                                
                                chatVM.getOtherUserByIDList(chatID: chat.id, id: membersID)}
                            
                            if let username = chatVM.userProfile?.username {
                                chatVM.chatUsernames[chat.id] = username
                            }
                        }
                        
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
//
//struct ChatRowView: View {
//    @EnvironmentObject var chatVM: ChatViewModel
//    let chat: Chat
//    
//    var body: some View {
//        NavigationLink {
//            ChatDetailView(currentChatID: chat.id)
//        } label: {
//            ChatRowContent(chat: chat)
//        }
//        .badge(chatVM.unreadMessagesCounts[chat.id] ?? 0)
//    }
//}
//
//struct ChatRowContent: View {
//    @EnvironmentObject var chatVM: ChatViewModel
//    let chat: Chat
//    @State var username: String = ""
//    var body: some View {
//        VStack {
//                Text(username)
//                Text(chat.name)
//                .task {
//                    if let chatMemberID = chat.members.first(where: { userID in
//                        userID != chatVM.currentUserID
//                    }) {
//                        chatVM.getOtherUserByID(id: chatMemberID)
//                    }
//                    if let memberName = chatVM.userProfile?.username {
//                        username = memberName
//                    }
//                }
//        }
//    }
//}
