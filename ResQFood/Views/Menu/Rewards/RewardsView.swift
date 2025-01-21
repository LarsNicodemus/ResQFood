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
            Text("Hier kannst du deine bisher erworbenen Punkte gegen Blohnungen eintauschen, \ndiese Wechseln also schau immer mal wieder rein.")
                .foregroundColor(Color("primaryAT"))
                .multilineTextAlignment(.leading)
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
                }
            }
            .listStyle(.plain)
        }
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

struct RewardSectionView: View {
    @EnvironmentObject var rewardVM: RewardViewModel
    var userPoints: Int
    var reward: Reward
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    var body: some View {
        let isInExactRange = rewardVM.isUserInSpecificRange(userPoints, for: reward)
        let isInRange = rewardVM.isUserInRange(userPoints, for: reward)

        Section(
            header: Text(isInExactRange ? "\(reward.lowerBound) - \(reward.upperBound) Punkte \nDu befindest dich hier!" : "\(reward.lowerBound) - \(reward.upperBound) Punkte")
                .font(.headline)
                .foregroundColor(isInRange ? Color("primaryAT") : Color("tertiary"))
        ) {
            ForEach(reward.rewards, id: \.points) { rewardItem in
                RewardItemView(userPoints: userPoints, rewardItem: rewardItem, showToast: $showToast, toastMessage: $toastMessage)
            }
        }
    }
}

struct RewardItemView: View {
    @EnvironmentObject var rewardVM: RewardViewModel
    var userPoints: Int
    var rewardItem: RewardItem
    @Binding var showToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        let isEligible = rewardVM.isUserEligibleForReward(userPoints, rewardItem: rewardItem)
        HStack {
            Text("\(rewardItem.points)")
                .frame(width: 50)
                .font(.body)
                .foregroundColor(isEligible ? Color("primaryAT") : Color("tertiary"))
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("\(rewardItem.description)")
                .font(.body)
                .foregroundColor(isEligible ? Color("primaryAT") : Color("tertiary"))
        }
        .onTapGesture {
            
            if isEligible {
                rewardVM.setUserPoints(points: rewardItem.points)
                withAnimation {
                    showToast = true
                    toastMessage = "\(rewardItem.description) ausgewählt, du wirst per Mail benachrichtigt."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showToast = false
                        toastMessage = ""
                    }
                }
            }
        }
    }
}

#Preview {
    RewardsView()
        .environmentObject(ProfileViewModel())
}
