//
//  HealthManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import Foundation
import HealthKit
import Combine
import SwiftUI
import CoreMotion
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
    // Track last heart rate alert zone to avoid repeat alerts
    private var lastHeartRateAlertZone: String?
    
    // Properties for handling alerts
    
    private var alertActive: Bool = false
    
    // Properties for tracking score and steps
    @Published var stepScore: Int = 0
    @Published var calScore: Int = 0
    @Published var kmScore: Int = 0
    @AppStorage("waterScore") var waterScore: Int = 0
    private var previousStepCount: Double = 0
    // เป็นส่วนการแสดงข้อมูลในกรณีที่ได้รับข้อมูลมาจาก health
    @Published var activities: [String: Activity] = [:]

    // MARK: - Gyro Inactivity Detection
    private var motionManager = CMMotionManager()
    private var accelerometerManager = CMMotionManager()
    private var inactivityTimer: Timer?
    private var lastMovementDate = Date()
    // Use a background operation queue for motion updates
    private let motionQueue = OperationQueue()

    init() {
        // เซ็ตค่า Mock Data เริ่มต้น
        setMockActivity(id: 0, key: "todaySteps", titleKey: "Today Steps", goalValue: "10,000", image: "figure.walk", tintColor: .gray, amount: "0")
        setMockActivity(id: 1, key: "todayCalories", titleKey: "Today Calories", goalValue: "900", image: "flame", tintColor: .gray, amount: "0")
        setMockActivity(id: 2, key: "todayHeartRate", titleKey: "Today Heart Rate", goalValue: "60-100 BPM", image: "heart.fill", tintColor: .gray, amount: "0 BPM")
        setMockActivity(id: 3, key: "dayDistance", titleKey: "Today's Distance", goalValue: "5 KM", image: "figure.walk.circle", tintColor: .gray, amount: "0")

        // Daily reset logic for calorie goal completion
        let lastResetDate = UserDefaults.standard.string(forKey: "lastCalorieScoreResetDate")
        let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastResetDate != todayString {
            UserDefaults.standard.set(false, forKey: "calGoalCompleted")
            UserDefaults.standard.set(todayString, forKey: "lastCalorieScoreResetDate")
        }

        // เริ่มจับเวลา
        startTimer()

        // กำหนดค่าประเภทข้อมูล HealthKit
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let water = HKQuantityType(.dietaryWater)
        let healthTypes: Set = [steps, calories, heartRate, distance, water]

        self.alertsManager = AlertsManager.shared

        // เริ่มจับความเคลื่อนไหวด้วย Gyro ก่อนขออนุญาต HealthKit
        startGyroMonitoring()

        // ขออนุญาตเข้าถึง HealthKit และเริ่มการสังเกตข้อมูลสุขภาพ
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                startObservingHealthData() // เริ่มดึงข้อมูลจาก HealthKit
                startTimer()
            } catch {
                print("Error requesting health data authorization: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Gyro & Accelerometer Monitoring & Inactivity
    private func startGyroMonitoring() {
        guard motionManager.isGyroAvailable, accelerometerManager.isAccelerometerAvailable else {
            print("Gyroscope or Accelerometer not available.")
            return
        }

        motionManager.gyroUpdateInterval = 1.0
        // Use the background operation queue instead of .main
        motionManager.startGyroUpdates(to: motionQueue) { [weak self] data, error in
            guard let self = self, let rotationRate = data?.rotationRate else { return }
            let magnitude = sqrt(rotationRate.x * rotationRate.x + rotationRate.y * rotationRate.y + rotationRate.z * rotationRate.z)
            if magnitude > 0.5 {
                self.lastMovementDate = Date()
                print("✅ Gyro movement at: \(self.lastMovementDate)") // ไปปิดไว้ได้ รกจอมาก
            }
        }

        accelerometerManager.accelerometerUpdateInterval = 1.0
        // Use the background operation queue instead of .main
        accelerometerManager.startAccelerometerUpdates(to: motionQueue) { [weak self] data, error in
            guard let self = self, let acceleration = data?.acceleration else { return }
            let magnitude = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)
            if abs(magnitude - 1.0) > 0.4 { // accounting for gravity
                self.lastMovementDate = Date()
                print("✅ Accelerometer movement at: \(self.lastMovementDate)") // ไปปิดไว้ได้ รกจอมาก
            }
        }

        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let timeSinceLastMovement = Date().timeIntervalSince(self.lastMovementDate)
            print("⏱ Time since last movement: \(timeSinceLastMovement)")
            if timeSinceLastMovement >= 60.0 {
                print("🚨 No movement detected for 1 min.")
                self.alertsManager?.triggerInactivityAlert()
            } else {
                print("✅ Movement detected within 1 min.")
            }
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 15, on: .main, in: .common) // Change to 15 seconds
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchTodaySteps()
                self?.fetchTodayCalories()
                self?.fetchTodayHeartRate()
                self?.fetchTodayDistance()
                self?.alertsManager?.scheduleWaterAlerts()
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
    
    // ประกาศตัวแปรแยกเฉพาะสำหรับคำนวณคะแนนเดิน
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("❌ Error fetching today's step data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.setMockStepActivity()
                }
                return
            }
            
            guard let quantity = result?.sumQuantity() else {
                print("⚠️ No step data available for today.")
                DispatchQueue.main.async {
                    self?.setMockStepActivity()
                }
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            let goalValue = "10,000 \(t("Steps", in: "Chart.Summary"))"

            
            // คำนวณคะแนนเดินแบบคำนวณครั้งเดียวจากจำนวนก้าวทั้งหมด
            // โดยที่ 100 ก้าว = 1 คะแนน
            let newScore = Int(stepCount / 100)
            DispatchQueue.main.async {
                ScoreManager.shared.stepScore = newScore
                print("StepScore updated to: \(newScore)")
            }
            
            DispatchQueue.main.async {
                let translatedTitle = t("Today Steps", in: "Chart_screen")
                let activity = Activity(
                    id: 0,
                    titleKey: translatedTitle,
                    subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                    image: "figure.walk",
                    tintColor: .green,
                    amount: stepCount.formattedString(),
                    goalValue: goalValue
                )
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
                print("❌ Error fetching today's Calories data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.setMockCaloriesActivity() // ✅ ใช้ Mock Data แทน
                }
                return
            }

            guard let quantity = result?.sumQuantity() else {
                print("⚠️ No calories data available for today.")
                DispatchQueue.main.async {
                    self?.setMockCaloriesActivity() // ✅ ใช้ Mock Data แทน
                }
                return
            }

            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let goalValue = "900 \(t("Kcal", in: "Chart.Summary"))"

            DispatchQueue.main.async {
                if ScoreManager.shared.stepScore > 0 {
                    let score = Int(caloriesBurned / 100) * 10
                    ScoreManager.shared.calScore = score
                    self?.calScore = score
                    print("✅ Calories recalculated: \(score) points.")
                }

                let translatedTitle = t("Today Calories", in: "Chart_screen")
                print("🌎 Translated Title: \(translatedTitle)")

                let activity = Activity(
                    id: 1,
                    titleKey: translatedTitle,  // ✅ ใช้ค่าที่แปลแล้ว
                    subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                    image: "flame",
                    tintColor: .red,
                    amount: caloriesBurned.formattedString(),
                    goalValue: goalValue
                )

                self?.activities["todayCalories"] = activity
                print("🔄 Updated Activity: \(activity.titleKey)")
            }
        }
        healthStore.execute(query)
    }

    func fetchTodayHeartRate() {
        let heartRateType = HKQuantityType(.heartRate)
        let stepCountType = HKQuantityType(.stepCount) // ✅ ตรวจสอบการเคลื่อนไหว
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] _, samples, error in
            if let error = error {
                print("❌ Error fetching today's HeartRate data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.setMockHeartRateActivity() // ✅ ใช้ Mock Data แทน
                }
                return
            }

            guard let samples = samples as? [HKQuantitySample], let latestSample = samples.first else {
                print("⚠️ No heart rate samples found.")
                DispatchQueue.main.async {
                    self?.setMockHeartRateActivity() // ✅ ใช้ Mock Data แทน
                }
                return
            }

            let heartRate = latestSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            let goalValue = "60-100 \(t("BPM", in: "Chart.Summary"))"

            DispatchQueue.main.async {
                let translatedTitle = t("Today Heart Rate", in: "Chart_screen")
                print("🌎 Translated Title: \(translatedTitle)")

                let activity = Activity(
                    id: 2,
                    titleKey: translatedTitle,
                    subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                    image: "heart.fill",
                    tintColor: .red,
                    amount: heartRate.formattedString(),
                    goalValue: goalValue
                )

                self?.activities["todayHeartRate"] = activity
                print("🔄 Updated Activity: \(activity.titleKey)")
            }

            // ✅ ดึงจำนวนก้าวเดินก่อนเรียก `evaluateHeartRateWarning()`
            let stepQuery = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    print("❌ Error fetching today's step data: \(error.localizedDescription)")
                    return
                }

                let stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                print("🚶‍♂️ Fetched Step Count: \(stepCount) steps")

                // ✅ เรียกใช้ฟังก์ชันตรวจสอบการแจ้งเตือน
                self?.evaluateHeartRateWarning(heartRate: heartRate, stepCount: stepCount)
            }
            self?.healthStore.execute(stepQuery)
        }
        healthStore.execute(query)
    }

    // ✅ ฟังก์ชันตรวจสอบ Heart Rate
    private func evaluateHeartRateWarning(heartRate: Double, stepCount: Double) {
        let isHeartRateVeryHigh = heartRate > 150
        let isHeartRateHigh = heartRate > 120 && heartRate <= 150
        let isHeartRateLow = heartRate >= 40 && heartRate < 60
        let isHeartRateNormal = heartRate >= 60 && heartRate <= 100
        let isHeartRateVeryLow = heartRate < 40

        print("🔍 Checking Heart Rate Warning...")
        print("💓 Heart Rate: \(heartRate) BPM")
        print("🚶‍♂️ Step Count: \(stepCount)")

        // Replace alert logic with zone tracking to avoid repeated alerts
        var newZone: String? = nil

        if isHeartRateVeryHigh {
            newZone = "veryHigh"
        } else if isHeartRateHigh {
            newZone = "high"
        } else if isHeartRateVeryLow {
            newZone = "veryLow"
        } else if isHeartRateLow {
            newZone = "low"
        } else if isHeartRateNormal {
            newZone = "normal"
        }

        if let zone = newZone, zone != lastHeartRateAlertZone {
            lastHeartRateAlertZone = zone
            switch zone {
            case "veryHigh":
                print("🚨 Triggering Very High Heart Rate Alert!")
                alertsManager?.triggerVeryHighHeartRateAlert()
            case "high":
                print("🚨 Triggering Heart Rate Alert!")
                alertsManager?.triggerHeartRateAlert()
            case "veryLow":
                print("🚨 Triggering Very Low Heart Rate Alert!")
                alertsManager?.triggerVeryLowHeartRateAlert()
            case "low":
                print("⚠️ Triggering Low Heart Rate Alert!")
                alertsManager?.triggerLowHeartRateAlert()
            case "normal":
                print("✅ Triggering Normal Heart Rate Notice!")
                alertsManager?.triggerNormalHeartRateNotice()
            default:
                break
            }
        } else if newZone != nil {
            print("🔁 Same heart rate zone, skipping alert.")
        } else {
            print("✅ Heart Rate is outside normal range, no alert triggered.")
        }

        // ✅ อัปเดตค่า previousStepCount เพื่อตรวจสอบว่ามีการเดินหรือไม่
        previousStepCount = stepCount
    }


    func fetchTodayDistance() {
        let distance = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("❌ Error fetching today's distance data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.setMockDistanceActivity() // ✅ ใช้ Mock Data แทน
                }
                return
            }

            guard let quantity = result?.sumQuantity() else {
                print("⚠️ No distance data available for today.")
                DispatchQueue.main.async {
                    self?.setMockDistanceActivity() // ✅ ใช้ Mock Data แทน
                }
                return
            }

            let distanceInMeters = quantity.doubleValue(for: .meter())
            let distanceInKilometers = distanceInMeters / 1000.0
            let goalValue = "5 \(t("KM", in: "Chart.Summary"))"

            DispatchQueue.main.async {
                let score = Int(distanceInKilometers) * 10
                ScoreManager.shared.kmScore = score
                self?.kmScore = score
                print("✅ Distance recalculated: \(score) points.")

                let translatedTitle = t("Today's Distance", in: "Chart_screen")
                print("🌎 Translated Title: \(translatedTitle)")

                let activity = Activity(
                    id: 3,
                    titleKey: translatedTitle,  // ✅ ใช้ค่าที่แปลแล้ว
                    subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
                    image: "figure.walk.circle",
                    tintColor: .blue,
                    amount: distanceInKilometers.formattedString(),
                    goalValue: goalValue
                )

                self?.activities["dayDistance"] = activity
                print("🔄 Updated Activity: \(activity.titleKey)")
            }
        }
        healthStore.execute(query)
    }

    private func setMockActivity(id: Int, key: String, titleKey: String, goalValue: String, image: String, tintColor: Color, amount: String) {
        print("⚠️ Using Mock Data for \(titleKey)")

        let mockActivity = Activity(
            id: id,
            titleKey: t(titleKey, in: "Chart_screen"),
            subtitleKey: "\(t("Goal", in: "Chart_screen")): \(goalValue)",
            image: image,
            tintColor: tintColor,
            amount: amount, // ✅ แสดงว่าไม่มีข้อมูลจริง
            goalValue: goalValue
        )

        self.activities[key] = mockActivity // ใช้ key ที่ถูกต้อง
        print("✅ Set Mock Data for \(titleKey) Activity")
    }
    private func setMockStepActivity() {
        setMockActivity(id: 0, key: "todaySteps", titleKey: "Today Steps", goalValue: "10,000", image: "figure.walk", tintColor: .gray, amount: "0")
    }

    private func setMockCaloriesActivity() {
        setMockActivity(id: 1, key: "todayCalories", titleKey: "Today Calories", goalValue: "900", image: "flame", tintColor: .gray, amount: "0")
    }

    private func setMockHeartRateActivity() {
        setMockActivity(id: 2, key: "todayHeartRate", titleKey: "Today Heart Rate", goalValue: "60-100 \(t("BPM", in: "Chart.Summary"))", image: "heart.fill", tintColor: .gray, amount: "0 \(t("BPM", in: "Chart.Summary"))")
    }

    private func setMockDistanceActivity() {
        setMockActivity(id: 3, key: "dayDistance", titleKey: "Today's Distance", goalValue: "5 \(t("KM", in: "Chart.Summary"))"
            , image: "figure.walk.circle", tintColor: .gray, amount: "0 \(t("KM", in: "Chart.Summary"))")
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
