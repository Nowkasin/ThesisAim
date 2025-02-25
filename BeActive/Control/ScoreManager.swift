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
}

