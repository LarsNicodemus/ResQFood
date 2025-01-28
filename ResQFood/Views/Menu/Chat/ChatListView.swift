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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                ScrollView {
                    var filteredChats: (creator: [Chat], receiver: [Chat]) {
                        let creator = chatVM.chats.filter { chat in
                            chat.admin == chatVM.currentUserID
                        }
                        let receiner = chatVM.chats.filter { chat in
                            chat.admin != chatVM.currentUserID
                        }
                        return (creator, receiner)
                    }

                    VStack(alignment: .leading) {
                        Text("Erhaltene Anfragen: ")
                            .font(Fonts.title2)
                            .foregroundStyle(Color("primaryAT"))
                            .multilineTextAlignment(.leading)
                        ForEach(filteredChats.creator) { chat in
                            ChatRowView(chat: chat)
                        }
                    }
                    .padding(.vertical)
                    VStack(alignment: .leading) {
                        Text("Angefragt: ")
                            .font(Fonts.title2)
                            .foregroundStyle(Color("primaryAT"))
                            .multilineTextAlignment(.leading)
                        ForEach(filteredChats.receiver) { chat in
                            ChatRowView(chat: chat)
                        }
                    }

                }
                .scrollIndicators(.hidden)
                .padding()
            }
        }
        .background(Color("surface"))
        .customBackButton()
    }
}

#Preview {
    ChatListView()
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(ProfileViewModel())
}



