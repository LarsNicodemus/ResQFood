//
//  ProfileView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//

import PhotosUI
import SwiftUI



struct ProfileView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    var userID: String
    var fromChat: Bool
    @State var fromChatForList: Bool = false
    @State var sheetPresent: Bool = false
    @State var isReportSheet: Bool = false
    @State var report: Bool = false
    @State private var activeSheet: ActiveSheet? = nil

    enum ActiveSheet: Identifiable {
            case report
            case message

            var id: String {
                switch self {
                case .report:
                    return "report"
                case .message:
                    return "message"
                }
            }
        }
    
    
    var body: some View {
        VStack {
            ScrollView {

                VStack {
                    if let user = profileVM.otherUserProfile {
                        HStack {
                            Spacer()
                            if fromChat {
                                Button {
                                    activeSheet = .report
                                } label: {
                                    Image(
                                        systemName:
                                            "exclamationmark.bubble.fill"
                                    )
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .tint(Color("primaryAT"))
                                }
                            } else {
                                Button {
                                    activeSheet = .report
                                } label: {
                                    Image(
                                        systemName:
                                            "exclamationmark.bubble.fill"
                                    )
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .tint(Color("primaryAT"))
                                }
                                Button {
                                    activeSheet = .message
                                } label: {
                                    Image(systemName: "ellipsis.message")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .tint(Color("primaryAT"))
                                }
                            }
                        }.padding(.trailing)
                        ProfileImageView(imageurl: user.pictureUrl)
                            .padding(.bottom, 32)

                        VStack {
                            StarRatingView()
                            let count = profileVM.ratedUsers.count
                            Text("Bewertungen: \(count)")
                        }

                        VStack(alignment: .leading, spacing: 20) {

                            HStack {
                                Image(systemName: "person.fill")
                                Text("Username: \(user.username)")
                                    .bold()
                            }

                            HStack {
                                Image(systemName: "star.fill")
                                Text(
                                    user.rating != nil
                                        ? "Bewertung: \(user.rating!)"
                                        : "Bewertung: noch keine Einträge.")
                            }

                            HStack {
                                Image(
                                    systemName:
                                        "point.3.connected.trianglepath.dotted")
                                Text("Gesammelte Punkte: \(user.points ?? 0)")
                            }

                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text(
                                    user.gender != nil
                                        ? "Geschlecht: \(user.gender!)"
                                        : "Geschlecht: nicht angegeben.")
                            }

                            if let city = user.location?.city,
                                let zip = user.location?.zipCode
                            {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "house.fill")
                                        Text("Standort:")
                                    }
                                    Text("\(zip) \(city)")
                                        .padding(.leading, 32)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(
                                Color("secondaryContainer"))
                        )
                        .shadow(radius: 5)
                        .applyTextColor(Color("OnPrimaryContainer"))
                    }
                }
                .padding()
                OtherProfilelistView(fromChat: Binding(
                                get: { fromChat },
                                set: {fromChatForList = $0 }
                            ))
                
            }
        }
        .background(Color("surface"))
        .customBackButton()
        .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .report:
                        ReportSheet(sheetPresent: .constant(false), report: .constant(true))
                            .presentationDetents([.medium])
                    case .message:
                        MessageSheet(sheetPresent: .constant(false))
                            .presentationDetents([.medium])
                    }
                }

        .onAppear {
            donVM.setupDonationsListenerForOtherUser(userID: userID)
            chatVM.getOtherUserByID(id: userID)
            profileVM.getOtherUserByIDList(id: userID)

        }

        .onChange(of: imageVM.selectedItem) { oldItems, newItems in
            Task {
                await imageVM.handleImageSelection(newItem: newItems)
                if imageVM.selectedImage != nil {
                    await imageVM.uploadImage()
                    profileVM.pictureUrl = imageVM.uploadedImage?.url
                    profileVM.editProfile(updates: [
                        .pictureUrl: profileVM.pictureUrl as Any
                    ])
                }
            }
        }
    }
}

#Preview {
    ProfileView(
        userID: "6WallALqOfVNtT78Ym5Bqd94Dw12", fromChat: true)
    .environmentObject(ProfileViewModel())
    .environmentObject(ImageViewModel())
    .environmentObject(ChatViewModel())
    .environmentObject(DonationViewModel())
    .environmentObject(MapViewModel())
}
