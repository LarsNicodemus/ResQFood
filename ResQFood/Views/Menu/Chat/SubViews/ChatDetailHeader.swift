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
    @Binding var details: Bool
    @Binding var title: String
    @Binding var chatMember: String
    @Binding var donationForTitle: FoodDonation?
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
            NavigationLink(title) {
                if let donation = donationForTitle {
                    DonationDetailView(donation: donation, showChat: $fromChat)
                        
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
    }
}
