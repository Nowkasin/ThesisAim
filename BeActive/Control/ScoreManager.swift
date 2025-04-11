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
    // ให้บันทึกคะแนนน้ำ และ การเดินลง DataBase ด้วย

    @Published var waterScore: Int = 0
    @Published var stepScore: Int = 0
    @Published var purchasedVouchers: [Voucher] = []

    // คำนวณคะแนนรวมเป็นผลรวมของ waterScore กับ stepScore
    var totalScore: Int {
        waterScore + stepScore
    }

    func addWaterScore(_ score: Int) {
        waterScore += score
        print("Water Score updated to: \(waterScore)")
    }

    func addStepScore(_ score: Int) {
        stepScore += score
        print("StepScore1 \(stepScore)")
    }

    // ใช้คะแนนรวม (step + water) เพื่อซื้อของอะไรก็ได้
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

    // ซื้อ Voucher และเก็บไว้ในประวัติ
    func purchaseVoucher(_ voucher: Voucher) -> Bool {
        if spendScore(voucher.cost) {
            purchasedVouchers.append(voucher)
            return true
        }
        return false
    }
}

