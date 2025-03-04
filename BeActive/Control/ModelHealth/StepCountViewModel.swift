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
            self?.fetchStepCount(for: .today) // ✅ โหลดข้อมูลใหม่เมื่อมีการเปลี่ยนแปลง
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
        var endDate: Date?
        var interval: DateComponents?

        switch range {
        case .today:
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
            interval = DateComponents(day: 1)

        case .week:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            endDate = now
            interval = DateComponents(day: 1) // ✅ ดึงข้อมูลรายวัน

        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            endDate = now
            interval = DateComponents(day: 1) // ✅ ดึงข้อมูลรายวัน

        case .sixMonths:
            startDate = calendar.date(byAdding: .month, value: -6, to: now)
            endDate = now
            interval = DateComponents(month: 1) // ✅ ดึงข้อมูลรายเดือน

        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))
            endDate = now
            interval = DateComponents(month: 1) // ✅ ดึงข้อมูลรายเดือน
        }

        guard let startDate = startDate, let endDate = endDate, let interval = interval else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: interval)

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
        var validDayCount: Int = 0 // ✅ นับเฉพาะวันที่มีการเดิน

        let calendar = Calendar.current
        let now = Date()
        let startDate: Date

        // ✅ ตั้งค่าช่วงเวลาให้แน่ใจว่าถูกต้อง
        switch range {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: now)! // ✅ ครอบคลุม 7 วันย้อนหลัง
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
            let steps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0

            stepData.append(StepData(date: currentDate, steps: steps))

            if steps > 0 { // ✅ นับเฉพาะวันที่มีการเดิน
                totalSteps += steps
                validDayCount += 1
            }

            currentDate = nextDate
        }

        self.stepCountData = stepData

        // ✅ คำนวณค่าเฉลี่ยเฉพาะวันที่มีการเดิน
        self.averageSteps = validDayCount > 0 ? totalSteps / Double(validDayCount) : 0

        print("Fetched Steps Data for \(range.rawValue): \(stepData)") // ✅ Debug
    }

    
    func filteredData(for range: TimeRange) -> [StepData] { // ✅ คืนค่าเป็น [StepData]
        return stepCountData
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
