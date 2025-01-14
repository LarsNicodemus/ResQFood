//
//
//  ZStackView1.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//
import SwiftUI

struct ZStackView1: View {
    @Binding var showToast: Bool
    var chatMemberID: String
    var donationID: String
    @Binding var details: Bool
    @Binding var toastMessage: String
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    var body: some View {
        ZStack {
            VStack(alignment: .trailing) {
                ZStack {
                    NavigationLink {
                        ProfileView(userID: chatMemberID, fromChat: true)
                            .onAppear {
                                        withAnimation {
                                            details = false
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
                            id: donationID, updates: [.isReserved: true])
                        donVM.editUserInfos(
                            userID: chatMemberID,
                            donationID: donationID,
                            to: .reserved
                        ) { result in
                            switch result {
                            case .success(let message):
                                toastMessage = message
                            case .failure(let error):
                                toastMessage = error.message
                            }
                            withAnimation {
                                showToast = true
                            }
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 2
                            ) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }

                        details = false
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
