//
//  DonationListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct DonationListView: View {
    @EnvironmentObject var donVM: DonationViewModel
    var body: some View {
        if let donations = donVM.donations {
        List{
                ForEach(donations, id: \.id) { donation in
                    DonationListItem(donation: donation)
                }
            }
        .listStyle(.plain)

        } else {
            EmptyListPlaceholder()
        }
    }
}

#Preview {
    DonationListView()
        .environmentObject(DonationViewModel())
}

