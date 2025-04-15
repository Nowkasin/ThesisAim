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
        var endDate: Date = now
        var interval: DateComponents?
        var anchorDate: Date = calendar.startOfDay(for: now)

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
            interval = DateComponents(day: 1)

        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)
            interval = DateComponents(day: 1)

        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            interval = DateComponents(day: 1)

        case .sixMonths:
            anchorDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            startDate = calendar.date(byAdding: .month, value: -6, to: anchorDate)
            interval = DateComponents(day: 1)

        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)
            interval = DateComponents(day: 1)
            anchorDate = calendar.startOfDay(for: now)
        }

        guard let startDate = startDate, let interval = interval else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
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
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        switch range {
        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)!
        default:
            startDate = calendar.startOfDay(for: now)
        }

        let stats = statsCollection.statistics()

        if range == .year {
            var monthlyDict: [Date: [Double]] = [:]

            for stat in stats {
                let date = stat.startDate
                guard date >= startDate && date < now else { continue }
                let distance = stat.sumQuantity()?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                monthlyDict[monthStart, default: []].append(distance)
                totalDistance += distance
            }

            for (date, distanceArray) in monthlyDict.sorted(by: { $0.key < $1.key }) {
                let valid = distanceArray.filter { $0 > 0 }
                let avg = valid.count > 0 ? valid.reduce(0, +) / Double(valid.count) : 0
                distanceData.append(DistanceData(time: date, distance: avg))
            }

            let totalDays = stats.filter { $0.startDate >= startDate && $0.startDate < now && $0.sumQuantity()?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0 > 0 }.count
            self.averageDistance = totalDays > 0 ? totalDistance / Double(totalDays) : 0
        }

        else if range == .sixMonths {
            let component: Calendar.Component = .weekOfYear
            var groupedDict: [Date: [Double]] = [:]

            for stat in stats {
                let date = stat.startDate
                guard !calendar.isDateInToday(date) else { continue }
                let distance = stat.sumQuantity()?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                let periodStart = calendar.dateInterval(of: component, for: date)?.start ?? date
                groupedDict[periodStart, default: []].append(distance)
                totalDistance += distance
            }

            for (date, distanceArray) in groupedDict.sorted(by: { $0.key < $1.key }) {
                let valid = distanceArray.filter { $0 > 0 }
                let avg = valid.count > 0 ? valid.reduce(0, +) / Double(valid.count) : 0
                distanceData.append(DistanceData(time: date, distance: avg))
            }

            let totalDays = stats.filter { !calendar.isDateInToday($0.startDate) }.count
            self.averageDistance = totalDays > 0 ? totalDistance / Double(totalDays) : 0
        }

        else {
            var currentDate = startDate
            var validDayCount = 0

            while currentDate <= now {
                let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                guard let statistics = statsCollection.statistics(for: currentDate) else {
                    currentDate = nextDate
                    continue
                }
                let distance = statistics.sumQuantity()?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                distanceData.append(DistanceData(time: currentDate, distance: distance))
                if distance > 0 {
                    totalDistance += distance
                    validDayCount += 1
                }
                currentDate = nextDate
            }

            self.averageDistance = validDayCount > 0 ? totalDistance / Double(validDayCount) : 0
        }

        self.distanceData = distanceData
        print("📊 ข้อมูลที่ดึงมา: \(distanceData)")
    }

    func filteredData(for range: TimeRange) -> [DistanceData] {
        return distanceData
    }

    func dateRangeText(for range: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en") // ใช้ชื่อเดือนอังกฤษเพื่อให้แปลได้
        formatter.dateStyle = .medium
        let now = Date()
        let calendar = Calendar.current

        switch range {
        case .today:
            return translatedDate(from: now, formatter: formatter)

        case .week:
            if let start = calendar.date(byAdding: .day, value: -6, to: now) {
                return "\(translatedDate(from: start, formatter: formatter)) - \(translatedDate(from: now, formatter: formatter))"
            }

        case .month:
            formatter.dateFormat = "MMM yyyy" // ใช้รูปแบบเดือนเต็ม เช่น April 2025
            return translatedDate(from: now, formatter: formatter)


        case .sixMonths:
            if let start = calendar.date(byAdding: .month, value: -6, to: now) {
                formatter.dateFormat = "MMM yyyy"
                return "\(translatedDate(from: start, formatter: formatter)) - \(translatedDate(from: now, formatter: formatter))"
            }

        case .year:
            if let start = calendar.date(byAdding: .year, value: -1, to: now) {
                formatter.dateFormat = "MMM yyyy"
                return "\(translatedDate(from: start, formatter: formatter)) - \(translatedDate(from: now, formatter: formatter))"
            }
        }

        return ""
    }

}
