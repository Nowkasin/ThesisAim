//
//  DistanctViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import Foundation
import HealthKit

class DistanceViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var distanceData: [(time: Date, distance: Double)] = []

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let typesToRead: Set = [distanceType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                DispatchQueue.global(qos: .background).async {
                    self.fetchTodayDistance()
                }
            } else {
                print("❌ Failed to get authorization: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func fetchTodayDistance() {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: DateComponents(hour: 1)
        )

        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("❌ Error fetching distance data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var newData: [(time: Date, distance: Double)] = []

            statsCollection.enumerateStatistics(from: startOfDay, to: Date()) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let distance = sum.doubleValue(for: HKUnit.meterUnit(with: .kilo))
                    newData.append((time: statistics.startDate, distance: distance))
                }
            }

            DispatchQueue.main.async {
                self.distanceData = newData
            }
        }

        healthStore.execute(query)
    }
}
