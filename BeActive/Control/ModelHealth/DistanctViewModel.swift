//
//  DistanctViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import Foundation
import HealthKit

// ✅ Struct สำหรับจัดการข้อมูลระยะทาง
struct DistanceData: Identifiable, Equatable {
    let id: UUID = UUID()
    let time: Date
    let distance: Double
}

class DistanceViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var distanceData: [DistanceData] = []
    @Published var averageDistance: Double = 0

    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        let typesToRead: Set = [distanceType]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("❌ Authorization error: \(error.localizedDescription)")
            }
        }
    }

    func fetchDistance(for range: TimeRange) {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date?
        var interval: DateComponents?

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
            interval = DateComponents(hour: 1) // ✅ ดึงข้อมูลรายชั่วโมง

        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)
            interval = DateComponents(day: 1) // ✅ ดึงข้อมูลรายวัน

        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            interval = DateComponents(day: 1) // ✅ ดึงข้อมูลรายวัน

        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)
            interval = DateComponents(month: 1) // ✅ ดึงข้อมูลรายเดือน

        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))
            interval = DateComponents(month: 1) // ✅ ดึงข้อมูลรายเดือน
        }

        guard let startDate = startDate, let interval = interval else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, results, _ in
            DispatchQueue.main.async {
                self.processDistanceData(results, range: range)
            }
        }

        query.statisticsUpdateHandler = { _, _, results, _ in
            DispatchQueue.main.async {
                self.processDistanceData(results, range: range)
            }
        }

        healthStore.execute(query)
    }

    private func processDistanceData(_ results: HKStatisticsCollection?, range: TimeRange) {
        guard let statsCollection = results else { return }

        var distanceData: [DistanceData] = []
        var totalDistance: Double = 0
        var validDayCount: Int = 0

        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch range {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)!
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
        default:
            startDate = calendar.startOfDay(for: now)
        }

        var currentDate = startDate
        while currentDate <= now {
            let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!

            let statistics = statsCollection.statistics(for: currentDate)
            let distance = statistics?.sumQuantity()?.doubleValue(for: .meter()) ?? 0

            distanceData.append(DistanceData(time: currentDate, distance: distance))

            if distance > 0 {
                totalDistance += distance
                validDayCount += 1
            }

            currentDate = nextDate
        }

        self.distanceData = distanceData

        // ✅ คำนวณค่าเฉลี่ยเฉพาะวันที่มีการเดินหรือวิ่งจริง
        self.averageDistance = validDayCount > 0 ? totalDistance / Double(validDayCount) : 0

        print("📊 Fetched Distance Data for \(range.rawValue): \(distanceData)") // ✅ Debug
    }

    func filteredData(for range: TimeRange) -> [DistanceData] { // ✅ คืนค่าเป็น [DistanceData]
        return distanceData
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
            if let start = calendar.date(byAdding: .day, value: -6, to: now) { // ✅ เริ่มจาก 6 วันก่อนหน้า
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
