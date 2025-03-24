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
    @Published var averageBPM: Double = 0.0

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
            startDate = calendar.date(byAdding: .year, value: -1, to: now)
        }

        guard let startDate = startDate else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: heartRateType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor]) { _, samples, _ in
            DispatchQueue.main.async {
                self.processSamples(samples: samples as? [HKQuantitySample], from: startDate, to: now, range: range)
            }
        }

        healthStore.execute(query)
    }

    private func processSamples(samples: [HKQuantitySample]?, from startDate: Date, to endDate: Date, range: TimeRange) {
        guard let samples = samples else { return }

        let calendar = Calendar.current
        var grouped: [Date: [Double]] = [:]
        var totalBPM: Double = 0
        var minBPM: Double = Double.infinity
        var maxBPM: Double = 0

        for sample in samples {
            let bpm = sample.quantity.doubleValue(for: .init(from: "count/min"))
            let bucketDate: Date

            switch range {
            case .today:
                bucketDate = calendar.date(bySettingHour: calendar.component(.hour, from: sample.startDate), minute: 0, second: 0, of: sample.startDate) ?? sample.startDate
            case .week, .month:
                bucketDate = calendar.startOfDay(for: sample.startDate)
            case .sixMonths:
                bucketDate = calendar.dateInterval(of: .weekOfYear, for: sample.startDate)?.start ?? sample.startDate
            case .year:
                bucketDate = calendar.date(from: calendar.dateComponents([.year, .month], from: sample.startDate)) ?? sample.startDate
            }

            grouped[bucketDate, default: []].append(bpm)
            totalBPM += bpm
            minBPM = min(minBPM, bpm)
            maxBPM = max(maxBPM, bpm)
        }

        let data = grouped.sorted { $0.key < $1.key }.map { key, values in
            let average = values.reduce(0, +) / Double(values.count)
            return HeartRateData(time: key, bpm: average)
        }

        self.heartRateData = data
        self.heartRateRange = data.isEmpty ? (0, 0) : (minBPM, maxBPM)
        self.averageBPM = samples.isEmpty ? 0 : totalBPM / Double(samples.count)
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
            if let start = calendar.date(byAdding: .year, value: -1, to: now) {
                formatter.dateFormat = "MMM yyyy"
                return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
            }
        }
        return ""
    }
}


