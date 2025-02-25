//
//  StepCountViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import Foundation
import HealthKit

class StepCountViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var stepCountData: [(date: Date, steps: Double)] = []
    @Published var averageSteps: Double = 0

    func fetchStepCount(for range: TimeRange) {  // ✅ ใช้ TimeRange ที่อยู่ในไฟล์แยก
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date?

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))
        }

        guard let startDate = startDate else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: now,
                                                intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { _, results, _ in
            DispatchQueue.main.async {
                guard let statsCollection = results else { return }

                var stepData: [(date: Date, steps: Double)] = []
                var totalSteps: Double = 0
                var count: Int = 0

                statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    stepData.append((date: statistics.startDate, steps: steps))
                    totalSteps += steps
                    count += 1
                }

                self.stepCountData = stepData
                self.averageSteps = count > 0 ? totalSteps / Double(count) : 0
            }
        }

        healthStore.execute(query)
    }

    func filteredData(for range: TimeRange) -> [(date: Date, steps: Double)] {
        return stepCountData
    }

    func dateRangeText(for range: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let now = Date()

        switch range {
        case .today:
            return formatter.string(from: now)
        case .week:
            if let start = Calendar.current.date(byAdding: .day, value: -6, to: now) {
                return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
            }
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: now)
        case .sixMonths:
            if let start = Calendar.current.date(byAdding: .month, value: -6, to: now) {
                return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
            }
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: now)
        }
        return ""
    }
}
