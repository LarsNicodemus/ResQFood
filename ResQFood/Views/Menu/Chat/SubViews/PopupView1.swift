//
//
//  ZStackView1.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//
import SwiftUI

struct PopupView1: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    var body: some View {
        ZStack {
            VStack(alignment: .trailing) {
                ZStack {
                    NavigationLink {
                        ProfileView(userID: chatVM.chatMemberID, fromChat: true)
                            .onAppear {
                                        withAnimation {
                                            chatVM.details = false
                                        }
                                    }
                    } label: {
                        Text("Profil")
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
                    .padding(.trailing, 4)

                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 95, alignment: .leading)
                        .offset(y: 15)
                }
                ZStack {
                    Button("reservieren") {
                        donVM.editDonation(
                            id: chatVM.donationID, updates: [.isReserved: true])
                        donVM.editUserInfos(
                            userID: chatVM.chatMemberID,
                            donationID: chatVM.donationID,
                            to: .reserved
                        ) { result in
                            switch result {
                            case .success(let message):
                                chatVM.toastMessage = message
                            case .failure(let error):
                                chatVM.toastMessage = error.message
                            }
                            withAnimation {
                                chatVM.showToastDetails = true
                            }
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 2
                            ) {
                                withAnimation {
                                    chatVM.showToastDetails = false
                                }
                            }
                        }

                        chatVM.details = false
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
                    .padding(.trailing, 4)

                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 95, alignment: .leading)
                        .offset(y: 15)
                }
            }
            .frame(width: 100, height: 70)
            .background(Color("surface"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.trailing)
            .padding(.top, 44)
        }
        .frame(
            maxWidth: .infinity, maxHeight: .infinity,
            alignment: .topTrailing)
    }
}
