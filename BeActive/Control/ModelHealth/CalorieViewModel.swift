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
    @Published var averageCalories: Double = 0

    func fetchCalories(for range: TimeRange) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date?
        var interval = DateComponents(day: 1)  // ✅ ค่าเริ่มต้นเป็นรายวัน

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)
            interval = DateComponents(month: 1)  // ✅ เปลี่ยนเป็นรายเดือน
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))
            interval = DateComponents(month: 1)  // ✅ เปลี่ยนเป็นรายเดือน
        }

        guard let startDate = startDate else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: now,
            intervalComponents: interval  // ✅ ปรับช่วงเวลาตาม TimeRange
        )

        query.initialResultsHandler = { _, results, _ in
            DispatchQueue.main.async {
                guard let statsCollection = results else { return }

                var newData: [(time: Date, calories: Double)] = []
                var totalCalories: Double = 0
                var count: Int = 0

                statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let calories = sum.doubleValue(for: .kilocalorie())
                        newData.append((time: statistics.startDate, calories: calories))
                        totalCalories += calories
                        count += 1
                    }
                }

                self.caloriesData = newData
                self.averageCalories = count > 0 ? totalCalories / Double(count) : 0
            }
        }

        healthStore.execute(query)
    }

    func filteredData(for range: TimeRange) -> [(time: Date, calories: Double)] {
        return caloriesData
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
