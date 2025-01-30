//
//  HealthManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import Foundation
import HealthKit
import Combine
// Extension for date handling
extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        return calendar.date(from: components) ?? Date()
    }
    
    static func startOfDay(earlierThan daysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: startOfDay) ?? Date()
    }
}

// Extension for number formatting
extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// HealthManager class
class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    var alertsManager: AlertsManager?
    private var timer: AnyCancellable?
    private var startTime: Date?
    private var alertStartTime: Date?
    
    // Properties for handling alerts
    
    private var alertActive: Bool = false
    
    // Properties for tracking score and steps
    @Published var stepScore: Int = 0
    private var previousStepCount: Double = 0
    
    // เป็นส่วนการแสดงข้อมูลในกรณีที่ได้รับข้อมูลมาจาก health
    @Published var activities: [String: Activity] = [
            "todaySteps": Activity(
                id: 0,
                titleKey: t("Today Steps", in: "Chart_screen"),
                subtitleKey: t("Goal", in: "Chart_screen"), // ✅ แปลคำว่า Goal เท่านั้น
                image: "figure.walk",
                tintColor: .green,
                amount: "0",
                goalValue: "10,000" // ✅ ใส่ค่าของ Goal ไว้ที่นี่
            ),
            "todayCalories": Activity(
                id: 1,
                titleKey: t("Today Calories", in: "Chart_screen"),
                subtitleKey: t("Goal", in: "Chart_screen"),
                image: "flame",
                tintColor: .orange,
                amount: "0",
                goalValue: "900"
            ),
            "todayHeartRate": Activity(
                id: 2,
                titleKey: t("Today Heart Rate", in: "Chart_screen"),
                subtitleKey: t("Goal", in: "Chart_screen"),
                image: "heart.fill",
                tintColor: .red,
                amount: "0 BPM",
                goalValue: "60-100 BPM"
            ),
            "dayDistance": Activity(
                id: 3,
                titleKey: t("Today's Distance", in: "Chart_screen"),
                subtitleKey: t("Goal", in: "Chart_screen"),
                image: "figure.walk.circle",
                tintColor: .blue,
                amount: "0",
                goalValue: "5 km"
            )

        ]
    var mockActivities: [String: Activity] = [
        "todaySteps": Activity(id: 0, titleKey: "Today Steps", subtitleKey: t("Goal", in: "Chart_screen"), image: "figure.walk", tintColor: .green, amount: "0", goalValue: "10,000"),
        "todayCalories": Activity(id: 1, titleKey: "Today Calories", subtitleKey: t("Goal", in: "Chart_screen"), image: "flame", tintColor: .orange, amount: "0", goalValue: "900"),
        "todayHeartRate": Activity(id: 2, titleKey: "Today Heart Rate", subtitleKey: t("Goal", in: "Chart_screen"), image: "heart.fill", tintColor: .red, amount: "0", goalValue: "60-100 BPM"),
        "dayDistance": Activity(id: 3, titleKey: "Today's Distance", subtitleKey: t("Goal", in: "Chart_screen"), image: "figure.walk.circle", tintColor: .blue, amount: "0", goalValue: "5 km")
    ]

    
    init() {
        startTimer()//เริ่มนับเวลาในแต่ละฟังก์ชั่น
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let water = HKQuantityType(.dietaryWater)
        let healthTypes: Set = [steps, calories, heartRate, distance, water]
        self.alertsManager = AlertsManager()
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                startObservingHealthData()//ประกาศ เพื่อเริ่มการทำงานของฟังก์ชั่นต่างๆ
                startTimer()
            } catch {
                print("Error requesting health data authorization: \(error.localizedDescription)")
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 2, on: .main, in: .common) // Change to 30 seconds
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchTodaySteps()
                self?.fetchTodayCalories()
                self?.fetchTodayHeartRate()
                self?.fetchTodayDistance()
                self?.alertsManager?.triggerWaterAlert()
            }
    }
    func startObservingHealthData() {
        // Define health data types
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let water = HKQuantityType(.dietaryWater)
        
        // Create a dictionary to map health types to corresponding fetch functions
        let healthDataMap: [HKQuantityType: () -> Void] = [
            steps: { [weak self] in self?.fetchTodaySteps() },
            calories: { [weak self] in self?.fetchTodayCalories() },
            heartRate: { [weak self] in self?.fetchTodayHeartRate() },
            distance: { [weak self] in self?.fetchTodayDistance() }
        ]
        
        let healthTypes = [steps, calories, heartRate, distance, water]
        
        for type in healthTypes {
            // Use HKObserverQuery to detect changes in data from Apple Watch
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            
            let query = HKObserverQuery(sampleType: type, predicate: devicePredicate, updateHandler: { [weak self] _, completionHandler, error in
                if let error = error {
                    print("Error observing \(type.identifier): \(error.localizedDescription)")
                    return
                }
                
                // Fetch the corresponding data based on the health data type
                DispatchQueue.main.async {
                    healthDataMap[type]?() // Call the associated fetch function
                }
                
                completionHandler() // Inform HealthKit that the work is done
            })
            healthStore.execute(query)
        }
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("Error fetching today's step data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.activities["todaySteps"] = self?.mockActivities["todaySteps"]
                }
                return
            }

            guard let quantity = result?.sumQuantity() else {
                print("No step data available for today.")
                DispatchQueue.main.async {
                    self?.activities["todaySteps"] = self?.mockActivities["todaySteps"]
                }
                return
            }

            let stepCount = quantity.doubleValue(for: .count())
            let goalValue = "10,000" // ✅ เปลี่ยนค่าคงที่เป็นตัวแปร

            let activity = Activity(
                id: 0,
                titleKey: t("Today Steps", in: "Chart_screen"),
                subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)", // ✅ ใช้ goalValue
                image: "figure.walk",
                tintColor: .green,
                amount: stepCount.formattedString(),
                goalValue: goalValue // ✅ เก็บค่า goalValue
            )

            DispatchQueue.main.async {
                self?.activities["todaySteps"] = activity
            }
        }
        healthStore.execute(query)
    }

    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("Error fetching today's Calories data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.activities["todayCalories"] = self?.mockActivities["todayCalories"]
                }
                return
            }

            guard let quantity = result?.sumQuantity() else {
                print("No calories data available for today.")
                DispatchQueue.main.async {
                    self?.activities["todayCalories"] = self?.mockActivities["todayCalories"]
                }
                return
            }

            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let goalValue = "900"

            let activity = Activity(
                id: 1,
                titleKey: t("Today Calories", in: "Chart_screen"),
                subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                image: "flame",
                tintColor: .red,
                amount: caloriesBurned.formattedString(),
                goalValue: goalValue
            )

            DispatchQueue.main.async {
                self?.activities["todayCalories"] = activity
            }
        }
        healthStore.execute(query)
    }

    func fetchTodayHeartRate() {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] _, samples, error in
            if let error = error {
                print("Error fetching today's HeartRate data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.activities["todayHeartRate"] = self?.mockActivities["todayHeartRate"]
                }
                return
            }

            guard let samples = samples as? [HKQuantitySample], let latestSample = samples.first else {
                print("No heart rate samples found.")
                DispatchQueue.main.async {
                    self?.activities["todayHeartRate"] = self?.mockActivities["todayHeartRate"]
                }
                return
            }

            let heartRate = latestSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let goalValue = "60-100 BPM"

            DispatchQueue.main.async {
                let activity = Activity(
                    id: 2,
                    titleKey: t("Today Heart Rate", in: "Chart_screen"),
                    subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                    image: "heart.fill",
                    tintColor: .red,
                    amount: heartRate.formattedString(),
                    goalValue: goalValue
                )

                self?.activities["todayHeartRate"] = activity
            }
        }
        healthStore.execute(query)
    }
    func fetchTodayDistance() {
        let distance = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("Error fetching today's distance data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.activities["dayDistance"] = self?.mockActivities["dayDistance"]
                }
                return
            }

            guard let quantity = result?.sumQuantity() else {
                print("No distance data available for today.")
                DispatchQueue.main.async {
                    self?.activities["dayDistance"] = self?.mockActivities["dayDistance"]
                }
                return
            }

            let distanceInMeters = quantity.doubleValue(for: .meter())
            let distanceInKilometers = distanceInMeters / 1000.0
            let goalValue = "5 km"

            let activity = Activity(
                id: 3,
                titleKey: t("Today's Distance", in: "Chart_screen"),
                subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                image: "figure.walk.circle",
                tintColor: .blue,
                amount: distanceInKilometers.formattedString(),
                goalValue: goalValue
            )

            DispatchQueue.main.async {
                self?.activities["dayDistance"] = activity
            }
        }
        healthStore.execute(query)
    }    
    func handleAlertDismiss() {
        DispatchQueue.main.async {
            self.alertActive = false // Alert is no longer active
            self.startTime = nil // Reset the timer now that the alert is dismissed
            print("Alert dismissed, resetting timer.")
        }
    }
    
    func requestAuthorization() {
        // ตรวจสอบว่า HealthKit สามารถใช้งานได้
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let typesToShare: Set = [heartRateType, stepCountType]
        let typesToRead: Set = [heartRateType, stepCountType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                print("Permission granted")
            } else {
                if let error = error {
                    print("Permission denied: \(error.localizedDescription)")
                } else {
                    print("Permission denied: Unknown error")
                }
            }
        }
    }
}
