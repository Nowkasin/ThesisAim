//
//  HeartRateViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import HealthKit
import SwiftUI

struct HeartRateData: Identifiable, Equatable {
    let id: UUID = UUID()
    let time: Date
    let bpm: Double
}

class HeartRateViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var heartRateData: [HeartRateData] = []
    @Published var heartRateRange: (min: Double, max: Double) = (0, 0)
    @Published var averageBPM: Double = 0.0  // ✅ เพิ่มค่าเฉลี่ย BPM

    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        let typesToRead: Set = [heartRateType]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Authorization error: \(error.localizedDescription)")
                } else {
                    print("✅ HealthKit authorization successful")
                }
            }
        }
    }

    func fetchHeartRate(for range: TimeRange) {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date?
        var interval: DateComponents?

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
            interval = DateComponents(hour: 1)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)
            interval = DateComponents(day: 1)
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            interval = DateComponents(day: 1)
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)
            interval = DateComponents(month: 1)
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))
            interval = DateComponents(month: 1)
        }

        guard let startDate = startDate, let interval = interval else {
            print("❌ Invalid date range")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage,
            anchorDate: startDate,
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, _ in
            DispatchQueue.main.async {
                self.processHeartRateData(results, range: range)
            }
        }

        query.statisticsUpdateHandler = { _, _, results, _ in
            DispatchQueue.main.async {
                self.processHeartRateData(results, range: range)
            }
        }

        healthStore.execute(query)
    }

    private func processHeartRateData(_ results: HKStatisticsCollection?, range: TimeRange) {
        guard let statsCollection = results else {
            print("❌ No heart rate data found")
            return
        }

        var heartRateData: [HeartRateData] = []
        var totalBPM: Double = 0
        var validDataCount: Int = 0
        var minBPM: Double = Double.infinity
        var maxBPM: Double = 0

        let calendar = Calendar.current
        let now = Date()
        let startDate: Date?

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

        var currentDate = startDate
        while currentDate <= now {
            guard let nextDate = calendar.date(byAdding: intervalUnit(for: range), value: 1, to: currentDate) else { break }

            if let statistics = statsCollection.statistics(for: currentDate),
               let avgQuantity = statistics.averageQuantity() {
                let bpm = avgQuantity.doubleValue(for: HKUnit(from: "count/min"))
                heartRateData.append(HeartRateData(time: currentDate, bpm: bpm))

                minBPM = min(minBPM, bpm)
                maxBPM = max(maxBPM, bpm)
                totalBPM += bpm
                validDataCount += 1
            }

            currentDate = nextDate
        }

        self.heartRateData = heartRateData
        self.heartRateRange = heartRateData.isEmpty ? (0, 0) : (minBPM, maxBPM)
        self.averageBPM = validDataCount > 0 ? totalBPM / Double(validDataCount) : 0.0
    }

    private func intervalUnit(for range: TimeRange) -> Calendar.Component {
        switch range {
        case .today:
            return .hour
        case .week, .month:
            return .day
        case .sixMonths, .year:
            return .month
        }
    }

    func filteredData(for range: TimeRange) -> [HeartRateData] {
        return heartRateData
    }

    func dateRangeText(for range: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let now = Date()
        let calendar = Calendar.current

        switch range {
        case .today:
            return formatter.string(from: now)
        case .week:
            if let start = calendar.date(byAdding: .day, value: -6, to: now) {
                return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
            }
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: now)
        case .sixMonths:
            if let start = calendar.date(byAdding: .month, value: -6, to: now) {
                return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
            }
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: now)
        }
        return ""
    }
}
