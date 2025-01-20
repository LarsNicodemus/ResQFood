//
//  DonationSection.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.01.25.
//
import SwiftUI

struct DonationSection: View {
    let title: String
    let donations: [FoodDonation]
    @EnvironmentObject var donVM: DonationViewModel
    
    var body: some View {
        if !donations.isEmpty {
            Section(header: Text(title)) {
                ForEach(donations, id: \.id) { donation in
                    CreateDonationListItem(donation: donation)
                        .task {
                            do {
                                let userID = try await donVM.getUserIdByDonationID(donation.id!)
                                donVM.getOtherUserByIDList(donID: donation.id!, id: userID)
                            } catch {
                                print("Fehler beim Abrufen des UserProfiles: \(error.localizedDescription)")
                            }
                        }
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                donVM.deleteDonation(id: donation.id!)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                                    .tint(Color("error"))
                            }
                            .containerShape(RoundedRectangle(cornerRadius: 15))
                            
                            Button {
                                donVM.handleReservedAction(donation: donation)
                            } label: {
                                Label("Reserviert", systemImage: "bookmark.fill")
                            }
                            .tint(Color("primaryAT"))
                            
                            Button {
                                Task {
                                    await donVM.handlePickedUpAction(donation: donation)
                                    do {
                                        let userID = try await donVM.getUserIdByDonationID(donation.id!)
                                        donVM.setUserPoints(otherUserID: userID)
                                        let weightInGrams = donVM.checkAndConvertWeightToGrams(donation: donation)
                                        donVM.setFoodWasteSaved(otherUserID: userID, foodWasteGramm: weightInGrams)
                                        withAnimation {
                                            donVM.showToast = true
                                        }
                                        DispatchQueue.main.asyncAfter(
                                            deadline: .now() + 2
                                        ) {
                                            withAnimation {
                                                donVM.showToast = false
                                            }
                                        }
                                    } catch {
                                        print("Fehler beim Abrufen des UserProfiles: \(error.localizedDescription)")
                                    }
                                }
                                

                            } label: {
                                Label("Vergeben", systemImage: "hand.raised.square")
                            }
                            .tint(Color("tertiary"))
                        }
                }
            }
        }
    }
}
