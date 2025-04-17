//
//  ScoreManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 23/2/2568 BE.
//

import SwiftUI
import Combine
import FirebaseFirestore

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    @AppStorage("waterScore") var waterScore: Int = 0
    @Published var stepScore: Int = 0
    @AppStorage("taskScore") var taskScore: Int = 0
    @AppStorage("lastTaskScoreResetDate") private var lastTaskScoreResetDate: String = ""

    @Published var purchasedVouchers: [Voucher] = []
    @Published var purchasedMates: [Mate] = []

    private let db = Firestore.firestore()
    @AppStorage("currentUserId") private var currentUserId: String = ""

    var totalScore: Int {
        waterScore + stepScore + taskScore
    }

    // ✅ Add score locally (now persists waterScore and taskScore)
    func addWaterScore(_ score: Int) {
        waterScore += score
        print("Water Score updated to: \(waterScore)")
    }

    func addStepScore(_ score: Int) {
        stepScore += score
        print("Step Score updated to: \(stepScore)")
    }

    func addTaskScore(_ score: Int) {
        taskScore += score
        print("Task Score updated to: \(taskScore)")
    }

    /// ✅ Call this once per day in .onAppear of TaskView to ensure score starts fresh daily
    func resetTaskScoreIfNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        if lastTaskScoreResetDate != today {
            taskScore = 0
            lastTaskScoreResetDate = today
            print("✅ Task score reset for a new day.")
        }
    }

    // ❌ This local method is still used internally but no longer called directly when purchasing
    private func spendLocalScore(_ cost: Int) -> Bool {
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

    // ✅ Firestore-based voucher purchase
    func purchaseVoucher(_ voucher: Voucher, completion: @escaping (Bool) -> Void) {
        guard !currentUserId.isEmpty else {
            print("❌ purchaseVoucher: currentUserId not set")
            completion(false)
            return
        }

        let userRef = db.collection("users").document(currentUserId)
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Firestore fetch error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = snapshot?.data(), let currentScore = data["score"] as? Int else {
                print("❌ Cannot retrieve score from Firestore.")
                completion(false)
                return
            }

            if currentScore >= voucher.cost {
                // ✅ Deduct in Firestore
                userRef.updateData(["score": currentScore - voucher.cost]) { error in
                    if let error = error {
                        print("❌ Failed to update score: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        DispatchQueue.main.async {
                            self.purchasedVouchers.append(voucher)
                        }
                        completion(true)
                    }
                }
            } else {
                print("❌ Not enough score in Firestore.")
                completion(false)
            }
        }
    }

    // ✅ Firestore-based mate purchase
    func purchaseMate(_ mate: Mate, completion: @escaping (Bool) -> Void) {
        guard !currentUserId.isEmpty else {
            print("❌ purchaseMate: currentUserId not set")
            completion(false)
            return
        }

        let userRef = db.collection("users").document(currentUserId)
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Firestore fetch error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = snapshot?.data(), let currentScore = data["score"] as? Int else {
                print("❌ Cannot retrieve score from Firestore.")
                completion(false)
                return
            }

            if currentScore >= mate.cost {
                // ✅ Deduct in Firestore
                userRef.updateData(["score": currentScore - mate.cost]) { error in
                    if let error = error {
                        print("❌ Failed to update score: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        DispatchQueue.main.async {
                            self.purchasedMates.append(mate)
                        }
                        completion(true)
                    }
                }
            } else {
                print("❌ Not enough score in Firestore.")
                completion(false)
            }
        }
    }
}
