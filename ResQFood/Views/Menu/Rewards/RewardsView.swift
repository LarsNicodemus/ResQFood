//
//  Rewards.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    var body: some View {
        VStack{
            Text("100 - 500 Punkte")
            Text("500 - 1000 Punkte")
            Text("1000 - 1500 Punkte")
            Text("1500 - 2000 Punkte")
            Text("2000 - 2500 Punkte")
            Text("2500 - 3000 Punkte")
        }
        .frame(maxWidth: .infinity)
            .customBackButton()

    }
}

#Preview {
    RewardsView()
        .environmentObject(ProfileViewModel())
}
