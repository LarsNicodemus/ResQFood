//
//  DonationListView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct DonationListView: View {
    @EnvironmentObject var mapVM: MapViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel
    @State var fromChat: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            let filteredDonations = mapVM.locationsInRadius.filter { donation in
                donation.pickedUp != true &&
                (mapVM.selectedItems.isEmpty ||
                 mapVM.selectedItems.contains(where: { $0.rawValue == donation.type }))
            }
            
            if !filteredDonations.isEmpty {
                ZStack {
                    Text("Ergebnisse: ")
                        .font(Fonts.title2)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(width: 150, alignment: .leading)
                        .foregroundStyle(Color("primaryAT"))
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, alignment: .leading)
                        .offset(y: 18)
                }
            ScrollView {
                    ForEach(filteredDonations, id: \.id) { donation in
                        Group {
                            if let isReserved = donation.isReserved, isReserved {
                                DonationListItem(donation: donation)
                            } else {
                                NavigationLink(
                                    destination: DonationDetailView(donation: donation, showChat: $fromChat)
                                ) {
                                    DonationListItem(donation: donation)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            
            else {
                VStack{
                    Spacer()
                    EmptyListPlaceholder(
                        firstText: "Keine Spenden verfügbar.",
                        secondText: "versuch vielleicht einen anderen Radius oder andere Filter."
                    )
                    Spacer()

                }
            }
        }
        
        .task {
            mapVM.setupDonationsListener()
            mapVM.updateLocationsInRadius()
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    DonationListView()
        .environmentObject(MapViewModel())
        .environmentObject(DonationViewModel())
        .environmentObject(ChatViewModel())

}
