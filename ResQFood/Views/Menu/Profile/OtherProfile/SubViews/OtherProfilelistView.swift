//
//  OtherProfilelistView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 25.01.25.
//

import SwiftUI

struct OtherProfilelistView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @Binding var fromChat: Bool
    var body: some View {
        VStack {
            Text("Weitere Inserate des Anbieters: ")

            if let donations = donVM.donations {
                let filteredDonations = donations.filter { donation in
                    donation.pickedUp != true
                }
                ForEach(filteredDonations, id: \.id) { donation in
                    Group {

                        if let isReserved = donation.isReserved, isReserved
                        {
                            DonationListItem(donation: donation)
                        } else {
                            NavigationLink(
                                destination: DonationDetailView(
                                    donation: donation, showChat: $fromChat)
                            ) {
                                DonationListItem(donation: donation)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
