//
//  DonationListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct DonationListView: View {
    @ObservedObject var mapVM: MapViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    var body: some View {
        VStack(alignment: .leading) {
            let filteredDonations = mapVM.locationsInRadius.filter { donation in
                donation.pickedUp != true
            }
            
            if !filteredDonations.isEmpty {
                Text("Ergebnisse: ")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical)
            }
            
            ScrollView {
                if !filteredDonations.isEmpty {
                    ForEach(filteredDonations, id: \.id) { donation in
                        Group {
                            if let isReserved = donation.isReserved, isReserved {
                                DonationListItem(donation: donation)
                            } else {
                                NavigationLink(
                                    destination: DonationDetailView(donation: donation)
                                ) {
                                    DonationListItem(donation: donation)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                } else {
                    EmptyListPlaceholder(
                        firstText: "Keine Spenden verfügbar.",
                        secondText: "versuch vielleicht einen anderen Radius oder andere Filter."
                    )
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color("primaryContainer").opacity(0.5)))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(!mapVM.locationsInRadius.isEmpty ? Color("primaryContainer").opacity(0.5) : Color.clear))
        .task {
            mapVM.setupDonationsListener()
            mapVM.updateLocationsInRadius()
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    DonationListView(mapVM: MapViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(ChatViewModel())

}
