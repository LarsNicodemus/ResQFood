//
//  DonationDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct DonationDetailView: View {
    var donation: FoodDonation
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var mapVM: MapViewModel
    var showChat: Bool
    @State var showToast: Bool = false
    @State var locationName: String = "Wird geladen..."
    var body: some View {

        ScrollView {
            VStack(alignment: .leading) {

                if let images = donation.picturesUrl {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(images, id: \.self) { image in
                                DetailImageView(imageurl: image)
                                    .frame(maxHeight: 250)
                            }
                        }
                    }
                    .padding()
                    .background(Color("secondaryContainer"))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("primaryAT"), lineWidth: 1)
                    }
                    .padding(.bottom, 8)
                    .scrollIndicators(.hidden)
                } else {
                    Image("placeholder")
                        .resizable()
                        .frame(width: .infinity)
                }
                
                
                DetailInfoView(donation: donation, locationName: $locationName, showChat: showChat)
                

                if (chatVM.chats.first(where: {
                    $0.members.contains(chatVM.currentUserID)
                        && $0.name == donation.title
                })?.id) != nil {
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            Image("placeholderIG")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)

                            Text("Anbieter \nbereits kontaktiert.")
                                .font(.title)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                        }
                        .padding()
                        Spacer()
                    }
                } else {

                    MessageView(showToast: $showToast, donation: donation)

                }

            }
            .overlay(
                Group {
                    if showToast {
                        ToastView(
                            message: "Nachricht wurde erfolgreich gesendet!"
                        )
                    }
                }
            )
            .task {
                chatVM.addChatsSnapshotListener()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("primaryContainer"))
            .foregroundStyle(Color("OnPrimaryContainer"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .overlay {
            if let id = donVM.getuserID() {
                if id == donation.creatorID {
                    ZStack {
                        Button {
                            donVM.isPresent = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .padding(4)
                        }
                        .padding(8)
                        .background(Color("primaryAT"))
                        .foregroundColor(Color("onPrimary"))
                        .clipShape(Circle())
                        .padding(8)
                        .frame(
                            maxWidth: .infinity, maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                    }
                }
            }
            
        }
        .sheet(isPresented: $donVM.isPresent) {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    DetailEditView(donation: donation, proxy: proxy)
                        .padding()
                }
            }
            
            .foregroundStyle(Color("primaryAT"))
        }
        .customBackButton()
        .background(Color("primaryContainer"))

    }
}

#Preview {
    DonationDetailView(donation: MockData.foodDonationMock, showChat: false)
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(MapViewModel())
        .environmentObject(ImageViewModel())
}



