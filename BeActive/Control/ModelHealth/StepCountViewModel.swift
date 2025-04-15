//
//  StepCountViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import Foundation
import HealthKit

// ✅ Struct สำหรับจัดการข้อมูลก้าวเดิน
struct StepData: Identifiable, Equatable {
    let id: UUID = UUID()
    let date: Date
    let steps: Double
}

class StepCountViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var stepCountData: [StepData] = []
    @Published var averageSteps: Double = 0

    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

    init() {
        requestAuthorization()
        startObservingStepCount()
    }

    private func requestAuthorization() {
        let typesToRead: Set = [stepCountType]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            }
        }
    }

    func startObservingStepCount() {
        let observerQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            self?.fetchStepCount(for: .today)
        }

        healthStore.execute(observerQuery)
        healthStore.enableBackgroundDelivery(for: stepCountType, frequency: .immediate) { success, error in
            if let error = error {
                print("Background delivery error: \(error.localizedDescription)")
            }
        }
    }

    func fetchStepCount(for range: TimeRange) {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date?
        var endDate: Date = now
        var interval: DateComponents?
        var anchorDate: Date = calendar.startOfDay(for: now)

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)!
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
            anchorDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
            startDate = calendar.date(byAdding: .year, value: -1, to: anchorDate)
            interval = DateComponents(day: 1)
        }

        guard let start = startDate, let intv = interval else { return }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: intv
        )

        query.initialResultsHandler = { _, results, _ in
            DispatchQueue.main.async {
                self.processStepData(results, range: range)
            }
        }

        query.statisticsUpdateHandler = { _, _, results, _ in
            DispatchQueue.main.async {
                self.processStepData(results, range: range)
            }
        }

        healthStore.execute(query)
    }

    private func processStepData(_ results: HKStatisticsCollection?, range: TimeRange) {
        guard let statsCollection = results else { return }

        var stepData: [StepData] = []
        var totalSteps: Double = 0
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let now = Date()

        switch range {
        case .year:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            let startMonth = calendar.dateInterval(of: .month, for: oneYearAgo)!.start
            let endMonth = calendar.dateInterval(of: .month, for: now)!.start
            var monthlyDict: [Date: (total: Double, count: Int)] = [:]
            var validDays = 0

            for stat in statsCollection.statistics() {
                let date = stat.startDate
                guard date >= startMonth && date <= endMonth else { continue }
                let steps = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

                monthlyDict[monthStart, default: (0, 0)].total += steps
                if steps > 0 {
                    monthlyDict[monthStart, default: (0, 0)].count += 1
                    totalSteps += steps
                    validDays += 1
                }
            }

            for (date, data) in monthlyDict.sorted(by: { $0.key < $1.key }) {
                let avg = data.count > 0 ? data.total / Double(data.count) : 0
                stepData.append(StepData(date: date, steps: avg))
            }

            self.averageSteps = validDays > 0 ? totalSteps / Double(validDays) : 0

        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            var currentDate = start
            while currentDate <= now {
                let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                guard let stat = statsCollection.statistics(for: currentDate) else {
                    currentDate = nextDate
                    continue
                }
                let steps = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                totalSteps += steps
                stepData.append(StepData(date: currentDate, steps: steps))
                currentDate = nextDate
            }
            let validDays = stepData.filter { $0.steps > 0 }.count
            self.averageSteps = validDays > 0 ? totalSteps / Double(validDays) : 0

        case .sixMonths:
            let start = calendar.date(byAdding: .month, value: -6, to: now)!
            var weeklyDict: [Date: [Double]] = [:]

            for stat in statsCollection.statistics() {
                let date = stat.startDate
                guard date >= start && !calendar.isDateInToday(date) else { continue }
                let steps = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
                weeklyDict[weekStart, default: []].append(steps)
                totalSteps += steps
            }

            for (date, stepsArray) in weeklyDict.sorted(by: { $0.key < $1.key }) {
                let valid = stepsArray.filter { $0 > 0 }
                let avg = valid.isEmpty ? 0 : valid.reduce(0, +) / Double(valid.count)
                stepData.append(StepData(date: date, steps: avg))
            }

            let totalDays = statsCollection.statistics().filter { !calendar.isDateInToday($0.startDate) }.count
            self.averageSteps = totalDays > 0 ? totalSteps / Double(totalDays) : 0

        default:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            var currentDate = start
            while currentDate <= now {
                let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                guard let stat = statsCollection.statistics(for: currentDate) else {
                    currentDate = nextDate
                    continue
                }
                let steps = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                totalSteps += steps
                stepData.append(StepData(date: currentDate, steps: steps))
                currentDate = nextDate
            }
            let validDays = stepData.filter { $0.steps > 0 }.count
            self.averageSteps = validDays > 0 ? totalSteps / Double(validDays) : 0
        }

        self.stepCountData = stepData
        print("📊 Fetched Steps Data for \(range.rawValue)")
        print("➡️ ค่าเฉลี่ยรวมแบบ HealthKit: \(self.averageSteps)")
    }

    func filteredData(for range: TimeRange) -> [StepData] {
        return stepCountData
    }

    func dateRangeText(for range: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en") // เพื่อให้ชื่อเดือนเป็นอังกฤษก่อน แล้วค่อยแปล
        let now = Date()
        let calendar = Calendar.current

        switch range {
        case .today:
            formatter.dateStyle = .medium
            return translatedDate(from: now, formatter: formatter)

        case .week:
            if let start = calendar.date(byAdding: .day, value: -6, to: now) {
                formatter.dateStyle = .medium
                let startStr = translatedDate(from: start, formatter: formatter)
                let endStr = translatedDate(from: now, formatter: formatter)
                return "\(startStr) - \(endStr)"
            }

        case .month:
            formatter.dateFormat = "MMM yyyy"
            return translatedDate(from: now, formatter: formatter)

        case .sixMonths:
            if let start = calendar.date(byAdding: .month, value: -6, to: now) {
                formatter.dateFormat = "MMM yyyy"
                let startStr = translatedDate(from: start, formatter: formatter)
                let endStr = translatedDate(from: now, formatter: formatter)
                return "\(startStr) - \(endStr)"
            }

        case .year:
            if let start = calendar.date(byAdding: .year, value: -1, to: now) {
                formatter.dateFormat = "MMM yyyy"
                let startStr = translatedDate(from: start, formatter: formatter)
                let endStr = translatedDate(from: now, formatter: formatter)
                return "\(startStr) - \(endStr)"
            }
        }
        return ""
    }
}

public protocol EquatableBytes: Equatable {
    init(bytes: [UInt8])
    var bytes: [UInt8] { get }
}
