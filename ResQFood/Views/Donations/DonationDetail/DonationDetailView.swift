//
//  DonationDetailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct DonationDetailView: View {
    var donation: FoodDonation
    var geoManager: GeocodingManager = GeocodingManager.shared
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel

    @State var showToast: Bool = false
    @State private var locationName: String = "Wird geladen..."
    var body: some View {
        
        ScrollView{
            VStack(alignment: .leading){
                
                    if let image = donation.picturesUrl?.first
                    {
                        DetailImageView(imageurl: image)
                            .padding(.bottom, 8)
                    } else {
                        Image("placeholder")
                            .resizable()
                            .frame(width: .infinity)
                    }
                HStack{
                    VStack{
                        Text(donation.title)
                            .font(.system(size: 20, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        Button("Kontakt"){
                            
                        }
                        .primaryButtonStyle()
                    }
                }
                .padding(.vertical)
                Text(donation.description)
                Text("Zustand: \(donation.condition)")
                let bbd = donation.bbd.formatted(.dateTime
                    .locale(Locale(identifier: "de-DE"))
                    .day()
                    .month()
                    .year()
                )
                Text("MHD bis: \(bbd)")
                let date = donation.expiringDate.formatted(.dateTime
                    .locale(Locale(identifier: "de-DE"))
                    .day()
                    .month()
                    .year()
                )
                Text("gültig bis: \(date)")
                let cdate = donation.creationDate.formatted(.dateTime
                    .locale(Locale(identifier: "de-DE"))
                    .day()
                    .month()
                    .year()
                )
                Text("erstellt am: \(cdate)")
                if let donator =  donation.creatorName {
                    Text("Ersteller: \(donator)")
                }
                if let contactInfo = donation.contactInfo {
                    if let number = contactInfo.number{
                    Text("Nummer: \(number)")}
                    if let mail = contactInfo.email {
                        Text("Mail: \(mail)")
                    }
                }
                Text("Wo? \(donation.preferredTransfer)")
                Text("Ort: \(locationName)")
                    .task {
                        locationName = await geoManager.getLocationName(latitude: donation.location.lat, longitude: donation.location.long)
                                }
                
//                if let chatID = chatVM.chats.first (where: {
//                    $0.members.contains(chatVM.currentUserID)
//                    && $0.name == donation.title
//                })?.id {
//                    HStack{
//                        Spacer()
//                        VStack(spacing: 20) {
//                            Image("placeholderIG")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 150, height: 150)
//                                .foregroundColor(.gray)
//                            
//                            Text("Anbieter \nbereits kontaktiert.")
//                                .font(.title)
//                                .foregroundColor(.gray)
//                            
//                        }
//                        .padding()
//                        Spacer()
//                    }
//                } else
//                    {
                        VStack{
                            ZStack{
                                
                                TextEditor(text: $chatVM.messageInput)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .background(Color("primaryContainer"))
                                if chatVM.messageInput.isEmpty {
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text("Bitte gib hier deine Nachricht ein...")
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            
                            Button(){
                                
                                if !chatVM.messageInput.isEmpty {
                                    
                                    chatVM.createChat(name: donation.title, userID: donation.creatorID, donationID: donation.id)
                                    withAnimation {
                                        showToast = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showToast = false
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "paperplane")
                                Text("Nachricht senden")
                            }
                            .primaryButtonStyle()
                            .padding(.bottom)
                            .padding(.bottom)
                        }
//                    }
                
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
        .customBackButton()

    }
}


#Preview {
    DonationDetailView(donation: MockData.foodDonationMock)
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
}
