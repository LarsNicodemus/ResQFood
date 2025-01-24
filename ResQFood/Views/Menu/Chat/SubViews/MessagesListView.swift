//
//  MessagesListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 24.01.25.
//

import SwiftUI

struct MessagesListView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var currentChatID: String

    var body: some View {
        VStack{
            List {
                ForEach(chatVM.messages) { message in
                    let fromSelf = message.senderID == chatVM.currentUserID
                    MessageItem(
                        content: message.content,
                        fromSelf: fromSelf,
                        timestamp: message.timestamp
                    )
                    .listRowBackground(Color("surface"))
                    .rotationEffect(Angle(degrees: -180))
                    .onAppear {
                        if !fromSelf && message.isread[chatVM.currentUserID] == false {
                            chatVM.markMessageAsRead(chatID: currentChatID, messageID: message.id!)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .listSectionSeparator(.hidden)
            .rotationEffect(Angle(degrees: 180))
        }.background(Color("surface"))
    }
}
