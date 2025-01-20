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
    @State var title: String = "TestSpendentitel"
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
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .tint(Color("primaryAT"))
                    }
                }.padding(.leading)
                Spacer()
                NavigationLink(title) {
                    if let donation = donationForTitle {
                        DonationDetailView(donation: donation)
                    }
                }
                .bold()
                .foregroundStyle(Color("tertiary"))
                Spacer()
                ZStack {
                    Text(chatMember)
                        .foregroundStyle(Color("primaryAT"))
                        .onChange(of: chatVM.userProfile?.username ?? "") {
                            oldValue, newValue in
                            chatMember = newValue
                        }
                        .onTapGesture {
                            details.toggle()
                        }
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, alignment: .leading)
                        .offset(y: 15)
                }

            }
            .frame(height: 44)
            .padding(.trailing)
            List {
                ForEach(chatVM.messages) { message in
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
                }
            }.listStyle(.plain)
                .scrollIndicators(.hidden)
                .listSectionSeparator(.hidden)
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

        .overlay(
            Group {
                if details {
                    if let donation = donationForTitle, donation.creatorID == chatVM.currentUserID {
                        ZStackView1(showToast: $showToast, chatMemberID: chatMemberID, donationID: donationID, details: $details, toastMessage: $toastMessage)
                    } else {
                        ZStackView2(chatMemberID: chatMemberID, details: $details)
                    }
                }
            }
        )
        .overlay(
            Group {
                if showToast {
                    ToastView(
                        message: toastMessage
                    )
                }
            }
        )
        .toolbarVisibility(.hidden, for: .navigationBar)

        .onAppear {
            chatVM.addMessageSnapshotListener(chatID: currentChatID)
            let chat = chatVM.chats.first { chat in
                chat.id == currentChatID
            }
            let donation = donVM.donations?.first(where: { donation in
                donation.id == chat?.donationID
            })
            donationForTitle = donation
            if let donationID = donation?.id {
                self.donationID = donationID
            }
            let donationCreatorID = donation?.creatorID
            if chatVM.currentUserID == donationCreatorID {
                userCreator = true
            }
            if let chatMemberID = chat?.members.first(where: { userID in
                userID != chatVM.currentUserID
            }) {
                chatVM.getOtherUserByID(id: chatMemberID)
                self.chatMemberID = chatMemberID
            }

            if let chatMember = chatVM.userProfile?.username {
                self.chatMember = chatMember
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




