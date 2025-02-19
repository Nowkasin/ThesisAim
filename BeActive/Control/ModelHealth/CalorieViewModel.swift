//
//  CalorieViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import Foundation
import HealthKit

class CalorieViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var caloriesData: [(time: Date, calories: Double)] = []

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let typesToRead: Set = [energyType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                DispatchQueue.global(qos: .background).async {
                    self.fetchTodayCalories()
                }
            } else {
                print("❌ Failed to get authorization: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func fetchTodayCalories() {
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: DateComponents(hour: 1)
        )

        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("❌ Error fetching calorie data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var newData: [(time: Date, calories: Double)] = []

            statsCollection.enumerateStatistics(from: startOfDay, to: Date()) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let calories = sum.doubleValue(for: .kilocalorie())
                    newData.append((time: statistics.startDate, calories: calories))
                }
            }

            DispatchQueue.main.async {
                self.caloriesData = newData
            }
        }

        healthStore.execute(query)
    }
}
