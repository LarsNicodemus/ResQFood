//
//  ChatDetailHeader.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 24.01.25.
//

import SwiftUI

struct ChatDetailHeader: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var chatVM: ChatViewModel
    @State var fromChat: Bool = true

    var body: some View {
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
            if let title = chatVM.title {
                NavigationLink(title) {
                    if let donation = chatVM.donationForTitle {
                        DonationDetailView(donation: donation, showChat: $fromChat)
                            
                    }
                }
                .bold()
                .foregroundStyle(Color("tertiary"))
            } else {
                Text("Nicht mehr verfügbar")
                    .bold()
                    .foregroundStyle(Color("tertiary"))
            }
            Spacer()
            ZStack {
                Text(chatVM.chatMember)
                    .foregroundStyle(Color("primaryAT"))
                    .onChange(of: chatVM.userProfile?.username ?? "") {
                        oldValue, newValue in
                        chatVM.chatMember = newValue
                    }
                    .onTapGesture {
                        chatVM.details.toggle()
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
    }
}
