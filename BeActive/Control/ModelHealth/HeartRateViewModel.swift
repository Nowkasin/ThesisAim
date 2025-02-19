//
//  HeartRateViewModel.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import HealthKit
import SwiftUI

class HeartRateViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var heartRateData: [(time: Date, bpm: Double)] = []
    @Published var heartRateRange: (min: Double, max: Double) = (0, 0)
    
    func fetchTodayHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                guard let self = self, let samples = samples as? [HKQuantitySample] else {
                    print("⚠️ No heart rate samples found or error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // แปลงข้อมูลเป็น array ของ [(time, bpm)]
                let heartRates = samples.map { sample in
                    (time: sample.endDate, bpm: sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
                }

                // อัปเดตค่า heartRateData
                self.heartRateData = heartRates

                // คำนวณช่วง BPM ต่ำสุดและสูงสุด
                if let minBPM = heartRates.map({ $0.bpm }).min(),
                   let maxBPM = heartRates.map({ $0.bpm }).max() {
                    self.heartRateRange = (minBPM, maxBPM)
                }
            }
        }
        healthStore.execute(query)
    }
}
