//
//  DonationsView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//

import SwiftUI

struct DonationsView: View {
    @EnvironmentObject var mapVM: MapViewModel
    @EnvironmentObject var chatVM: ChatViewModel

    var body: some View {
            VStack{
                DonationMapView()
                    .ignoresSafeArea(edges: .top)
               
            }
            .background(Color("surface"))
            .toolbarBackground(Color("surface"), for: .tabBar)
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    DonationsView()
        .environmentObject(DonationViewModel())
        .environmentObject(ChatViewModel())
        .environmentObject(MapViewModel())
}
