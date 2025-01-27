//
//  ChatDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

struct ChatDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel


    var currentChatID: String
    var body: some View {
        VStack {
            ChatDetailHeader()

            MessagesListView(
                currentChatID: currentChatID
            )

            MessageInputItem(currentChatID: currentChatID)
        }
        .background(Color("surface"))
        .overlay(
            Group {
                if chatVM.details {
                    if let donation = chatVM.donationForTitle, donation.creatorID == chatVM.currentUserID {
                        PopupView1()
                    } else {
                        PopupView2()
                    }
                }
            }
        )
        .overlay(
            Group {
                if chatVM.showToastDetails {
                    ToastView(message: chatVM.toastMessage)
                }
            })
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            setupChat()
        }
        .onDisappear {
            chatVM.deinitChat()
        }
    }

    private func setupChat() {
        chatVM.addMessageSnapshotListener(chatID: currentChatID)
        let chat = chatVM.chats.first { $0.id == currentChatID }
        
        if let chatMemberID = chat?.members.first(where: { $0 != chatVM.currentUserID }) {
            chatVM.getOtherUserByID(id: chatMemberID)
            chatVM.chatMemberID = chatMemberID
            if chatVM.currentUserID == chat?.admin {
                donVM.setupDonationsListenerForUser()
            } else {
                donVM.setupDonationsListenerForOtherUser(userID: chatMemberID)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let donation = self.donVM.donations?.first(where: { $0.id == chat?.donationID })
                chatVM.donationForTitle = donation
                chatVM.donationID = donation?.id ?? ""
                chatVM.userCreator = self.chatVM.currentUserID == donation?.creatorID
                chatVM.title = donation?.title ?? chatVM.title
            }
        }
        chatVM.chatMember = chatVM.userProfile?.username ?? chatVM.chatMember
    }
}


#Preview {
    ChatDetailView(currentChatID: "51456C01-3EAB-4CF7-A639-F2F48E38A041")
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())

}




