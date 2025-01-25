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
    @State var fromChat: Bool = true

    var body: some View {
        if !donations.isEmpty {
            Text(title).bold().listRowBackground(Color.clear)
            ForEach(donations, id: \.id) { donation in
                NavigationLink(
                    destination: DonationDetailView(
                        donation: donation, showChat: $fromChat)
                ) {
                    CreateDonationListItem(donation: donation)
                }
                .colorMultiply(Color.clear)
                .listRowBackground(Color.clear)
                .overlay{
                    CreateDonationListItem(donation: donation)
                }
                .task {
                    do {
                        let userID = try await donVM.getUserIdByDonationID(
                            donation.id!)
                        donVM.getOtherUserByIDList(
                            donID: donation.id!, id: userID)
                    } catch {
                        print(
                            "Fehler beim Abrufen des UserProfiles: \(error.localizedDescription)"
                        )
                    }
                }
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    SwipeView(donation: donation)
                }
            }
        }
    }
}
