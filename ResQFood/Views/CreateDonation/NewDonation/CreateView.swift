//
//  CreateView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import PhotosUI
import SwiftUI

struct CreateView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var locVM: LocationViewModel
    @EnvironmentObject var imageVM: ImageViewModel
    @State var userid: String? = nil
    
    // Extrahierte Funktionen für die Button-Aktionen
    private func handlePickedUpAction(donation: FoodDonation) async {
        let newValue = (donation.pickedUp ?? false) == true ? false : true
        donVM.editDonation(id: donation.id!, updates: [.pickedUp: newValue])
        
        if donation.isReserved == true {
            donVM.editDonation(id: donation.id!, updates: [.isReserved: false])
        }
        
        do {
            let userID = try await donVM.getUserIdByDonationID(donation.id!)
            userid = userID
            
            donVM.editUserInfos(userID: userID, donationID: donation.id!, to: .collected) { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print(error.message)
                }
            }
        } catch {
            print("Fehler beim Abrufen der UserID: \(error.localizedDescription)")
        }
    }
    
    private func handleReservedAction(donation: FoodDonation) {
        let newValue = (donation.isReserved ?? false) == true ? false : true
        donVM.editDonation(id: donation.id!, updates: [.isReserved: newValue])
    }
    
    var body: some View {
        VStack {
            List {
                if let donations = donVM.donations {
                    ForEach(donations, id: \.id) { donation in
                        CreateDonationListItem(donation: donation)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // Delete Button
                                Button {
                                    donVM.deleteDonation(id: donation.id!)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                        .tint(Color("error"))
                                }
                                .containerShape(RoundedRectangle(cornerRadius: 15))
                                
                                // Reserve Button
                                Button {
                                    handleReservedAction(donation: donation)
                                } label: {
                                    Label("Reserviert", systemImage: "bookmark.fill")
                                }
                                .tint(Color("primaryAT"))
                                
                                // Picked Up Button
                                Button {
                                    Task {
                                        await handlePickedUpAction(donation: donation)
                                    }
                                } label: {
                                    Label("Vergeben", systemImage: "hand.raised.square")
                                }
                                .tint(Color("tertiary"))
                            }
                    }
                } else {
                    EmptyListPlaceholder(
                        firstText: "keine aktiven Spenden",
                        secondText: "erstell gerne eine Spende ;)")
                }
            }
            .listStyle(.plain)

        }
        .overlay {
            ZStack {
                Button {
                    donVM.isPresent = true
                } label: {
                    Image(systemName: "cross.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(8)
                }
                .padding()
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .primaryButtonStyle()
            }
        }
        .onAppear {
            donVM.setupDonationsListenerForUser()
        }
        .sheet(isPresented: $donVM.isPresent) {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    InputElementsView(proxy: proxy)
                        .padding()
                }
            }
            .overlay(
                Group {
                    if donVM.showToast {
                        ToastView(
                            message: donVM.uploadSuccessMessage
                                ?? "Etwas ist schief gelaufen!")
                    }
                }
            )
            .foregroundStyle(Color("primaryAT"))
        }

    }
}

#Preview {
    CreateView()
        .environmentObject(DonationViewModel())
        .environmentObject(LocationViewModel())
        .environmentObject(ImageViewModel())
}
