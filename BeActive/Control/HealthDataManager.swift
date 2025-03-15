//
//  HealthDataManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/3/2568 BE.
//

import SwiftUI
import HealthKit

@MainActor
class HealthDataManager: ObservableObject {
    @Published var healthStats: HealthStats = .placeholder
    private var healthStore = HKHealthStore()
    private var timer: Timer?

    init() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task {
                await self.fetchHealthData()
            }
        }
    }

    func fetchHealthData() async {
        async let steps = fetchTodaySteps()
        async let calories = fetchTodayCalories()
        async let heart = fetchTodayHeartRate()
        async let dist = fetchTodayDistance()

        let newStats = await HealthStats(
            stepCount: steps,
            caloriesBurned: calories,
            heartRate: heart,
            distance: dist
        )

        Task { @MainActor in
            if self.healthStats != newStats {
                self.healthStats = newStats
                NotificationCenter.default.post(name: .healthDataUpdated, object: newStats) // ✅ แจ้งเตือนเฉพาะเมื่อข้อมูลเปลี่ยน
            }
        }
    }

    private func fetchTodaySteps() async -> String {
        let stepsType = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: "\(Int(value))")
            }
            healthStore.execute(query)
        }
    }

    private func fetchTodayCalories() async -> String {
        let caloriesType = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: "\(Int(value)) kcal")
            }
            healthStore.execute(query)
        }
    }

    private func fetchTodayHeartRate() async -> String {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) ?? 0
                continuation.resume(returning: "\(Int(value)) BPM")
            }
            healthStore.execute(query)
        }
    }

    private func fetchTodayDistance() async -> String {
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = (result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0) / 1000
                continuation.resume(returning: String(format: "%.2f km", value))
            }
            healthStore.execute(query)
        }
    }
}

extension Notification.Name {
    static let healthDataUpdated = Notification.Name("healthDataUpdated")
}

// ✅ Struct เทียบค่าได้
struct HealthStats: Equatable {
    let stepCount: String
    let caloriesBurned: String
    let heartRate: String
    let distance: String
    
    static let placeholder = HealthStats(stepCount: "--", caloriesBurned: "--", heartRate: "--", distance: "--")
}
