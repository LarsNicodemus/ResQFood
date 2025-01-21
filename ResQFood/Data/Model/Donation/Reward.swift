//
//  Reward.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.01.25.
//

import Foundation

struct Reward: Identifiable {
    let id = UUID()
    let lowerBound: Int
    let upperBound: Int
    let rewards: [RewardItem]
}
