//
//  RewardSectionView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 24.01.25.
//

import SwiftUI

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
