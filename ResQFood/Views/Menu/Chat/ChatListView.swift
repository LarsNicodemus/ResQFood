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
                ScrollView{
                    ForEach(chatVM.chats) { chat in
                        ChatRowView(chat: chat)
                    }
                }
                .padding()
            }
        }
        .customBackButton()
        .onAppear {
                   chatVM.addChatsSnapshotListener()
               }
    }
}

#Preview {
    ChatListView()
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
}

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

struct ChatRowContent: View {
    @EnvironmentObject var chatVM: ChatViewModel
    let chat: Chat
    @State var username: String = ""
    var body: some View {
        ZStack{
            
            VStack(alignment: .leading) {
                
                
                
                HStack {
                    Text("Betreff: \(chat.name)")
                        .foregroundStyle(Color("OnSecondaryContainer"))
                        .bold()
                    
                    Spacer()
                    Text(chat.lastMessage.formatted())
                        .font(.system(size: 10))
                        .fontWeight(chatVM.unreadMessagesCounts[chat.id] ?? 0 > 0 ? .bold : .regular)

                        .foregroundStyle(chatVM.unreadMessagesCounts[chat.id] ?? 0 > 0 ? Color("tertiary") : Color("OnSecondaryContainer"))

                }
                if let username = chatVM.chatUsernames[chat.id] {
                    Text("Von: \(username)")
                        .foregroundStyle(Color("OnSecondaryContainer"))

                }
                if let lastMessageContent = chatVM.lastMessagesContent[chat.id] {
                                Text(lastMessageContent)
                                    .font(.body)
                                    .fontWeight(chatVM.unreadMessagesCounts[chat.id] ?? 0 > 0 ? .bold : .regular)
                                    .lineLimit(1)
                                    .italic()
                                    .foregroundStyle(chatVM.unreadMessagesCounts[chat.id] ?? 0 > 0 ? Color("tertiary") : Color("OnSecondaryContainer"))
                            } else {
                                Text("Lade Nachrichten...")
                                    .font(.body)
                                    .foregroundStyle(Color("OnSecondaryContainer"))
                            }
            }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("primaryAT"),lineWidth: 1)
        }
            if chatVM.unreadMessagesCounts[chat.id] ?? 0 > 0{
                ZStack{
                    Circle()
                        .fill(Color("tertiary").opacity(0.4))
                        .frame(width: 40, height: 40)
                    Text("\(chatVM.unreadMessagesCounts[chat.id] ?? 0)").foregroundStyle(Color("tertiary"))
                        .bold()
                }
                .offset(x:150,y:10)
            }
        }
        .padding(.top)
        .task {
            if let membersID = chat.members.first(where: { id in
                id != chatVM.currentUserID
            }) {
                chatVM.getOtherUserByIDList(chatID: chat.id, id: membersID)
            }
            
            if let username = chatVM.userProfile?.username {
                chatVM.chatUsernames[chat.id] = username
            }
        }
        .onAppear {
                    chatVM.addMessageSnapshotListener(chatID: chat.id)
                }
    }
}
