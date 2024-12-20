//
//  DonationListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct DonationListView: View {
    @ObservedObject var mapVM: MapViewModel

    @EnvironmentObject var donVM: DonationViewModel
    var body: some View {
        if !mapVM.locationsInRadius.isEmpty {
            List {
                let donations = mapVM.locationsInRadius
                ForEach(donations, id: \.id) { donation in

                    DonationListItem(donation: donation)
                }
            }.listStyle(.plain)
        } else {
            EmptyListPlaceholder()
        }

    }
}

#Preview {
    DonationListView(mapVM: MapViewModel())
        .environmentObject(DonationViewModel())
}
