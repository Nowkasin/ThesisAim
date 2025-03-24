//
//  CalorieViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import Foundation
import HealthKit

// ✅ Struct สำหรับจัดการข้อมูลแคลอรี่
struct CalorieData: Identifiable, Equatable {
    let id: UUID = UUID()
    let time: Date
    let calories: Double
}

class CalorieViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var caloriesData: [CalorieData] = []
    @Published var averageCalories: Double = 0

    private let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        let typesToRead: Set = [calorieType]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            }
        }
    }

    func fetchCalories(for range: TimeRange) {
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
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: intv
        )

        query.initialResultsHandler = { _, results, _ in
            DispatchQueue.main.async {
                self.processCalorieData(results, range: range)
            }
        }

        query.statisticsUpdateHandler = { _, _, results, _ in
            DispatchQueue.main.async {
                self.processCalorieData(results, range: range)
            }
        }

        healthStore.execute(query)
    }

    private func processCalorieData(_ results: HKStatisticsCollection?, range: TimeRange) {
        guard let statsCollection = results else { return }

        var calorieData: [CalorieData] = []
        var totalCalories: Double = 0
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
                let calories = stat.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!

                monthlyDict[monthStart, default: (0, 0)].total += calories
                if calories > 0 {
                    monthlyDict[monthStart, default: (0, 0)].count += 1
                    totalCalories += calories
                    validDays += 1
                }
            }

            for (date, data) in monthlyDict.sorted(by: { $0.key < $1.key }) {
                let avg = data.count > 0 ? data.total / Double(data.count) : 0
                calorieData.append(CalorieData(time: date, calories: avg))
            }

            self.averageCalories = validDays > 0 ? totalCalories / Double(validDays) : 0

        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            var currentDate = start
            while currentDate <= now {
                let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                guard let stat = statsCollection.statistics(for: currentDate) else {
                    currentDate = nextDate
                    continue
                }
                let calories = stat.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                totalCalories += calories
                calorieData.append(CalorieData(time: currentDate, calories: calories))
                currentDate = nextDate
            }
            let validDays = calorieData.filter { $0.calories > 0 }.count
            self.averageCalories = validDays > 0 ? totalCalories / Double(validDays) : 0

        case .sixMonths:
            let start = calendar.date(byAdding: .month, value: -6, to: now)!
            var weeklyDict: [Date: [Double]] = [:]

            for stat in statsCollection.statistics() {
                let date = stat.startDate
                guard date >= start && !calendar.isDateInToday(date) else { continue }
                let calories = stat.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
                weeklyDict[weekStart, default: []].append(calories)
                totalCalories += calories
            }

            for (date, caloriesArray) in weeklyDict.sorted(by: { $0.key < $1.key }) {
                let valid = caloriesArray.filter { $0 > 0 }
                let avg = valid.isEmpty ? 0 : valid.reduce(0, +) / Double(valid.count)
                calorieData.append(CalorieData(time: date, calories: avg))
            }

            let totalDays = statsCollection.statistics().filter { !calendar.isDateInToday($0.startDate) }.count
            self.averageCalories = totalDays > 0 ? totalCalories / Double(totalDays) : 0

        default:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            var currentDate = start
            while currentDate <= now {
                let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                guard let stat = statsCollection.statistics(for: currentDate) else {
                    currentDate = nextDate
                    continue
                }
                let calories = stat.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                totalCalories += calories
                calorieData.append(CalorieData(time: currentDate, calories: calories))
                currentDate = nextDate
            }
            let validDays = calorieData.filter { $0.calories > 0 }.count
            self.averageCalories = validDays > 0 ? totalCalories / Double(validDays) : 0
        }

        self.caloriesData = calorieData
        print("\u{1F4CA} Fetched Calories Data for \(range.rawValue)")
        print("\u{27A1}\u{FE0F} ค่าเฉลี่ยรวมแบบ HealthKit: \(self.averageCalories)")
    }

    func filteredData(for range: TimeRange) -> [CalorieData] {
        return caloriesData
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
