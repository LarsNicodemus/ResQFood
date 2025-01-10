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
        if !mapVM.locationsInRadius.isEmpty {
            ScrollView{
                    let donations = mapVM.locationsInRadius
                    ForEach(donations, id: \.id) { donation in
                        NavigationLink(destination: DonationDetailView(donation: donation)) {
                            DonationListItem(donation: donation)
                        }
                    }
                }
            .scrollIndicators(.hidden)
        } else {
            EmptyListPlaceholder(firstText: "Keine Spenden verfügbar.", secondText: "versuch vielleicht einen anderen Radius oder andere Filter.")
        }

    }
}

#Preview {
    DonationListView(mapVM: MapViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(ChatViewModel())

}
