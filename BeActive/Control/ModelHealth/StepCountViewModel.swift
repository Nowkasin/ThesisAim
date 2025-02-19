//
//  StepCountViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import HealthKit

class StepCountViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var stepCountData: [(date: Date, steps: Double)] = []
    @Published var stepCountRange: (min: Double, max: Double) = (0, 0)

    func fetchWeeklyStepCount() {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: now,
                                                intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { query, results, error in
            DispatchQueue.main.async {
                guard let statsCollection = results else { return }

                var stepData: [(date: Date, steps: Double)] = []
                statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    stepData.append((date: statistics.startDate, steps: steps))
                }

                self.stepCountData = stepData

                if let minSteps = stepData.map({ $0.steps }).min(),
                   let maxSteps = stepData.map({ $0.steps }).max() {
                    self.stepCountRange = (minSteps, maxSteps)
                }
            }
        }

        healthStore.execute(query)
    }
}
