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
    @State var title: String? = nil
    @State var chatMember: String = "Hasibububär"
    @State var chatMemberID: String = ""
    @State var donationID: String = ""
    @State var details: Bool = false
    @State var userCreator: Bool = false
    @State var showToast: Bool = false
    @State var toastMessage: String = ""
    @State var donationForTitle: FoodDonation? = nil

    var currentChatID: String
    var body: some View {
        VStack {
            ChatDetailHeader(
                details: $details,
                title: $title,
                chatMember: $chatMember,
                donationForTitle: $donationForTitle
            )

            MessagesListView(
                currentChatID: currentChatID
            )

            MessageInputItem(currentChatID: currentChatID)
        }
        .background(Color("surface"))
        .overlay(DetailsOverlay())
        .overlay(ToastOverlay())
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            setupChat()
        }
        .onDisappear {
            chatVM.deinitChat()
        }
    }

    private func DetailsOverlay() -> some View {
        Group {
            if details {
                if let donation = donationForTitle, donation.creatorID == chatVM.currentUserID {
                    ZStackView1(
                        showToast: $showToast,
                        chatMemberID: chatMemberID,
                        donationID: donationID,
                        details: $details,
                        toastMessage: $toastMessage
                    )
                } else {
                    ZStackView2(chatMemberID: chatMemberID, details: $details)
                }
            }
        }
    }

    private func ToastOverlay() -> some View {
        Group {
            if showToast {
                ToastView(message: toastMessage)
            }
        }
    }

    private func setupChat() {
        chatVM.addMessageSnapshotListener(chatID: currentChatID)
        let chat = chatVM.chats.first { $0.id == currentChatID }
        
        if let chatMemberID = chat?.members.first(where: { $0 != chatVM.currentUserID }) {
            chatVM.getOtherUserByID(id: chatMemberID)
            self.chatMemberID = chatMemberID
            if chatVM.currentUserID == chat?.admin {
                donVM.setupDonationsListenerForUser()
            } else {
                donVM.setupDonationsListenerForOtherUser(userID: chatMemberID)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let donation = self.donVM.donations?.first(where: { $0.id == chat?.donationID })
                self.donationForTitle = donation
                self.donationID = donation?.id ?? ""
                self.userCreator = self.chatVM.currentUserID == donation?.creatorID
                self.title = donation?.title ?? self.title
            }
        }
        chatMember = chatVM.userProfile?.username ?? chatMember
    }
}


#Preview {
    ChatDetailView(currentChatID: "51456C01-3EAB-4CF7-A639-F2F48E38A041")
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())

}




