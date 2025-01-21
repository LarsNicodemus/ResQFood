//
//  RewardItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.01.25.
//
import Foundation

struct RewardItem: Identifiable {
    let id = UUID()
    let points: Int
    let description: String
}
