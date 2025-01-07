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
                            .frame(width: .infinity, height: 200)
                            
                            Button(){
                                if !chatVM.messageInput.isEmpty {
                                    chatVM.createChat3(name: donation.title, userID: donation.creatorID)
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
            .frame(width: .infinity)
            .padding()
            .background(Color("primaryContainer"))
            .foregroundStyle(Color("OnPrimaryContainer"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}


#Preview {
    DonationDetailView(donation: FoodDonation(creatorID: "1212", creatorName: "Lars", creationDate: Date(), title: "TestDonation", description: "Lebensmittel", type: "Obst", weight: 100.0, weightUnit: "gramm", bbd: Date(), condition: "gut", picturesUrl: ["https://i.imgur.com/1ejoivh.jpeg"], location: AppLocation(lat: 50.23, long: 8.40), preferredTransfer: "zu Hause", expiringDate: Date(), contactInfo: ContactInfo(email: "test@test.de", number: "01234567891011")))
        .environmentObject(ChatViewModel())
}
