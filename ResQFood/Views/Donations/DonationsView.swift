//
//  DonationsView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//

import SwiftUI

struct DonationsView: View {
    @StateObject var mapVM: MapViewModel = MapViewModel()

    var body: some View {
        VStack{
            DonationMapView(mapVM: mapVM)
            DonationListView(mapVM: mapVM)
        }
    }
}

#Preview {
    DonationsView()
        .environmentObject(DonationViewModel())
}
