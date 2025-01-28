//
//  ChatRowContent.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

struct ChatRowContent: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var donVM: DonationViewModel

    let chat: Chat
    @State var username: String = ""
    @State var isDonationAvailable: Bool = true
    @State var isDonationReservedOrPickedUp: Bool = true

    var body: some View {
        ZStack {

            VStack(alignment: .leading) {

                HStack {
                    Text("Betreff: \(chat.name)")
                        .foregroundStyle(Color("OnSecondaryContainer"))
                        .bold()

                    Spacer()
                    Text(chat.lastMessage.formatted())
                        .font(.system(size: 10))
                        .fontWeight(
                            chatVM.unreadCountPerChat[chat.id] ?? 0 > 0
                                ? .bold : .regular
                        )

                        .foregroundStyle(
                            chatVM.unreadCountPerChat[chat.id] ?? 0 > 0
                                ? Color("tertiary")
                                : Color("OnSecondaryContainer"))

                }
                if chatVM.currentUserID == chatVM.lastMessagesSender[chat.id] {
                        Text("Du: ")
                            .foregroundStyle(Color("OnSecondaryContainer"))
                } else {
                    if let username = chatVM.chatUsernames[chat.id] {
                        Text("Von: \(username)")
                            .foregroundStyle(Color("OnSecondaryContainer"))
                    }
                }
                HStack {
                    if chatVM.currentUserID
                        == chatVM.lastMessagesSender[chat.id]
                    {
                        Image("arrow1")
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        Image("arrow3")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .rotationEffect(Angle(degrees: 180))
                    }
                    if let lastMessageContent = chatVM.lastMessagesContent[
                        chat.id]
                    {

                        Text(lastMessageContent)
                            .font(.body)
                            .fontWeight(
                                chatVM.unreadCountPerChat[chat.id] ?? 0 > 0
                                    ? .bold : .regular
                            )
                            .lineLimit(1)
                            .italic()
                            .foregroundStyle(
                                chatVM.unreadCountPerChat[chat.id] ?? 0 > 0
                                    ? Color("tertiary")
                                    : Color("OnSecondaryContainer"))
                    } else {
                        Text("Lade Nachrichten...")
                            .font(.body)
                            .foregroundStyle(Color("OnSecondaryContainer"))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                isDonationReservedOrPickedUp
                ? Color("tertiaryContainer").opacity(0.7)
                        : Color("secondaryContainer")
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("primaryAT"), lineWidth: 1)
            }
            if chatVM.unreadCountPerChat[chat.id] ?? 0 > 0 {
                ZStack {
                    Circle()
                        .fill(Color("tertiary").opacity(0.4))
                        .frame(width: 40, height: 40)
                    Text("\(chatVM.unreadCountPerChat[chat.id] ?? 0)")
                        .foregroundStyle(Color("tertiary"))
                        .bold()
                }
                .offset(x: 150, y: 10)
            }
        }
        .opacity(isDonationAvailable ? 1 : 0.5)
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
            if let donationID = chat.donationID {
                Task {
                    let availability = await donVM.checkDonationAvailability(id: donationID)
                    let reservedOrPickedUp = await donVM.checkDonationReservedOrPickedUp(id: donationID)
                    
                    print("Donation Availability: \(availability)")
                    print("Donation Reserved or Picked Up: \(reservedOrPickedUp)")

                    DispatchQueue.main.async {
                        isDonationAvailable = availability
                        isDonationReservedOrPickedUp = reservedOrPickedUp
                    }
                }
            }
        }
    }
}

