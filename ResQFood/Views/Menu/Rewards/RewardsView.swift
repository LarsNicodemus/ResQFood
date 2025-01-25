//
//  Rewards.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var rewardVM: RewardViewModel = RewardViewModel()
    @State var showToast: Bool = false
    @State var toastMessage: String = ""

    var body: some View {
        VStack {
            ZStack {
                Text("Rewards")
                    .font(Fonts.title)
                    .foregroundStyle(Color("primaryAT"))
                Image("Strich")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .offset(y: 18)
            }
            Text("Hier kannst du deine bisher erworbenen Punkte gegen Blohnungen eintauschen, \ndiese Wechseln also schau immer mal wieder rein.")
                .foregroundColor(Color("primaryAT"))
                .multilineTextAlignment(.center)
                .padding(.top)
                .padding(.bottom)
            let userPoints = profileVM.userProfile?.points ?? 0
            Text("Dein aktueller Punktestand: \(userPoints)")
                .font(.headline)
                .bold()
                .foregroundColor(Color("primaryAT"))
                
            List {
                ForEach(rewardVM.rewardsData) { reward in
                    RewardSectionView(userPoints: userPoints, reward: reward, showToast: $showToast, toastMessage: $toastMessage)
                        .environmentObject(rewardVM)
                        .listRowBackground(Color("surface"))
                }
            }
            .listStyle(.plain)
        }
        .background(Color("surface"))
        .overlay {
            if showToast {
                ToastView(message: toastMessage)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .customBackButton()
    }
}





#Preview {
    RewardsView()
        .environmentObject(ProfileViewModel())
        .environmentObject(RewardViewModel())
}
