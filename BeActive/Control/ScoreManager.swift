//
//  ScoreManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 23/2/2568 BE.
//

import SwiftUI
import Combine

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    @Published var waterScore: Int = 0
    @Published var stepScore: Int = 0
    @Published var purchasedVouchers: [Voucher] = []
    @Published var purchasedMates: [Mate] = []

    var totalScore: Int {
        waterScore + stepScore
    }

    func addWaterScore(_ score: Int) {
        waterScore += score
        print("Water Score updated to: \(waterScore)")
    }

    func addStepScore(_ score: Int) {
        stepScore += score
        print("Step Score updated to: \(stepScore)")
    }

    // Use score to purchase something (prioritize stepScore first)
    func spendScore(_ cost: Int) -> Bool {
        guard totalScore >= cost else { return false }

        if stepScore >= cost {
            stepScore -= cost
        } else {
            let remaining = cost - stepScore
            stepScore = 0
            waterScore -= remaining
        }

        return true
    }

    // Purchase voucher
    func purchaseVoucher(_ voucher: Voucher) -> Bool {
        if spendScore(voucher.cost) {
            purchasedVouchers.append(voucher)
            return true
        }
        return false
    }

    // Purchase mate
    func purchaseMate(_ mate: Mate) -> Bool {
        if spendScore(mate.cost) {
            purchasedMates.append(mate)
            return true
        }
        return false
    }
}

