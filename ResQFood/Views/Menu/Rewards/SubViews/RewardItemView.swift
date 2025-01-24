//
//  RewardItemView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 24.01.25.
//
import SwiftUI

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
