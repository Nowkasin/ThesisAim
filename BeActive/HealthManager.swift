//
//  HealthManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import Foundation
import HealthKit
import Combine
import UserNotifications
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
    private var timer: AnyCancellable?
    private var moveAlertTimer: Timer?
    private var isAlertActive = false
    private var startTime: Date?
    private var alertStartTime: Date?
    
    // Properties for handling alerts
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    private var alertActive: Bool = false
    
    // Properties for tracking score and steps
    @Published var stepScore: Int = 0
    private var previousStepCount: Double = 0
    
    // เป็นส่วนการแสดงข้อมูลในกรณีที่ได้รับข้อมูลมาจาก health
    @Published var activities: [String: Activity] = [
        "todaySteps": Activity(id: 0, title: "Today Steps", subtitle: "Goal 10,000", image: "figure.walk", tintColor: .green, amount: "0"),
        "todayCalories": Activity(id: 1, title: "Today Calories", subtitle: "Goal 900", image: "flame", tintColor: .red, amount: "0"),
        "todayHeartRate": Activity(id: 2, title: "Today Heart Rate", subtitle: "Goal 60-100 BPM", image: "heart.fill", tintColor: .red, amount: "0 BPM"),
        "dayDistance": Activity(id: 3, title: "Today's Distance", subtitle: "Goal 5 km", image: "figure.walk.circle", tintColor: .blue, amount: "0")
        
    ]
    // เป็นส่วนการแสดงข้อมูลในกรณีที่ไม่ได้รับข้อมูลมาจาก health
    @Published var mockActivities: [String: Activity] = [
        "todaySteps": Activity(id: 0, title: "Today Steps", subtitle: "Goal 10,000", image: "figure.walk", tintColor: .green, amount: "0"),
        "todayCalories": Activity(id: 1, title: "Today Calories", subtitle: "Goal 900", image: "flame", tintColor: .red, amount: "0"),
        "todayHeartRate": Activity(id: 2, title: "Today Heart Rate", subtitle: "Goal 60-100 BPM", image: "heart.fill", tintColor: .red, amount: "0 BPM"),
        "dayDistance": Activity(id: 3, title: "Today's Distance", subtitle: "Goal 5 km", image: "figure.walk.circle", tintColor: .blue, amount: "0"),
    ]
    
    init() {
        startTimer()//เริ่มนับเวลาในแต่ละฟังก์ชั่น
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let healthTypes: Set = [steps, calories, heartRate, distance]
        
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
            }
    }
    func startObservingHealthData() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let healthTypes = [steps, calories, heartRate, distance]

        for type in healthTypes {
            // Use HKObserverQuery to detect changes in data from Apple Watch
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            
            let query = HKObserverQuery(sampleType: type, predicate: devicePredicate, updateHandler: { [weak self] _, completionHandler, error in
                if let error = error {
                    print("Error observing \(type.identifier): \(error.localizedDescription)")
                    return
                }

                // Call a function to fetch data from Apple Watch
                DispatchQueue.main.async {
                    switch type {
                    case steps:
                        self?.fetchTodaySteps()
                    case calories:
                        self?.fetchTodayCalories()
                    case heartRate:
                        self?.fetchTodayHeartRate()
                    case distance:
                        self?.fetchTodayDistance()
                    default:
                        break
                    }
                }

                completionHandler() // Inform HealthKit that the work is done
            })
            healthStore.execute(query)
        }
    }

    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())//เริ่มจับการเคลื่อนไหวเมื่อถึงเที่ยงคืนวันต่อไป และจะรีเซ็ตค่าเมื่อสิ้นสุดวันนั้น
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in//สร้างเพื่อนับจำนวนก้าวที่เกิดขึ้นในช่วงเวลานั้น
            if let error = error {
                print("Error fetching today's step data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.activities["todaySteps"] = self?.mockActivities["todaySteps"]
                }//ตรวจสอบข้อผิดพลาด
                return
            }
            //ตรวจสอบว่ามีข้อมูลจำนวนก้าวหรือไม่ ถ้าไม่มีให้แสดงข้อมูลแบบจำลองแทน
            guard let quantity = result?.sumQuantity() else {
                print("No step data available for today.")
                DispatchQueue.main.async {
                    self?.activities["todaySteps"] = self?.mockActivities["todaySteps"]
                }
                return
            }
            //นำข้อมูลจำนวนก้าวไปแสดงในหน้า ui
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Today Steps", subtitle: "Goal 10,000", image: "figure.walk", tintColor: .green, amount: stepCount.formattedString())
            //อัปเดตข้อมูลใหม่ไปยังหน้า ui
            DispatchQueue.main.async {
                self?.activities["todaySteps"] = activity
                
                // Update step score with new rule: 100 steps = 1 point
                let newPoints = Int(stepCount / 100) - Int(self?.previousStepCount ?? 0) / 100
                if newPoints > 0 {
                    self?.stepScore += newPoints
                }
                
                self?.previousStepCount = stepCount
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
            let activity = Activity(id: 1, title: "Today Calories", subtitle: "Goal 900", image: "flame", tintColor: .red, amount: caloriesBurned.formattedString())
            
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
            
            // Define heart rate ranges
            let sleepHeartRateRange = 40.0...64.0
            let restingHeartRateRange = 65.0...85.0 // Adjust based on gender
            let walkingHeartRateRange = 86.0...120.0 // Adjust based on gender
            
            print("Current Heart Rate: \(heartRate)")

            DispatchQueue.main.async {
                var state: String = "Unknown"
                
                // Determine the state based on heart rate range
                if restingHeartRateRange.contains(heartRate) {
                    state = "Resting"
                } else if walkingHeartRateRange.contains(heartRate) {
                    state = "Walking"
                } else if sleepHeartRateRange.contains(heartRate){
                    state = "Sleep"
                }
                else {
                    self?.startTime = nil
                    print("Heart rate out of target range. Resetting timer.")
                }
                
                print("Current State: \(state)")
                
                if walkingHeartRateRange.contains(heartRate) || restingHeartRateRange.contains(heartRate) {
                    if self?.startTime == nil && self?.alertActive == false {
                        // Start timer when heart rate is in range and no alert is active
                        self?.startTime = Date()
                        print("Started timing: \(self?.startTime ?? Date())")
                    }
                    
                    let elapsedTime = Date().timeIntervalSince(self?.startTime ?? Date())
                    print("Elapsed Time in target range: \(elapsedTime) seconds")
                    
                    if elapsedTime >= 300 && self?.alertActive == false { // 5 minute
                        self?.triggerMoveAlert()
                        // Wait for the user to dismiss the alert before resetting startTime
                    }
                }

                let activity = Activity(id: 2, title: "Today Heart Rate (\(state))", subtitle: "Goal 60-120 BPM", image: "heart.fill", tintColor: .red, amount: heartRate.formattedString())
                self?.activities["todayHeartRate"] = activity
            }
        }
        healthStore.execute(query)
    }

    func Waterperday() {
        // Create a notification content
        let content = UNMutableNotificationContent()
        content.title = "ดื่มน้ำแล้ว!"
        content.body = "ถึงเวลาดื่มน้ำแล้วนะ!"
        content.sound = .default
        
        // Set up notification trigger to repeat every hour
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        
        // Create a notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling water reminder notification: \(error.localizedDescription)")
            } else {
                print("Water reminder notification scheduled successfully.")
            }
        }
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
            let activity = Activity(id: 3, title: "Today's Distance", subtitle: "Goal 5 km", image: "figure.walk.circle", tintColor: .blue, amount: distanceInKilometers.formattedString())
            
            DispatchQueue.main.async {
                self?.activities["dayDistance"] = activity
            }
        }
        healthStore.execute(query)
    }
    
    private func triggerMoveAlert() {
        if !isAlertActive { // ตรวจสอบว่ามีการแจ้งเตือนอยู่หรือไม่
            let content = UNMutableNotificationContent()
            content.title = "เดินได้แล้ว!"
            content.body = "คุณนั่งนานเกิน 5 นาที ลุกขึ้นเดินได้แล้ว!"
            content.sound = .default

            // กำหนดให้แจ้งเตือนซ้ำทุก 5 นาที
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)  // เริ่มต้นทันที
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error triggering notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully")
                    self.isAlertActive = true  // ตั้งค่าว่ามีการแจ้งเตือนแล้ว
                    print("isAlertActive set to true")

                    // เริ่มการนับเวลาใหม่
                    self.scheduleNextAlertAfterDelay()  // ไม่มีความจำเป็นต้องใช้ resetTimer parameter
                }
            }
        } else {
            print("Alert is already active, waiting for 5 minutes.")
        }
    }

    private func scheduleNextAlertAfterDelay() {
        print("Starting 5 minute delay")

        // หน่วงเวลา 5 นาทีโดยใช้ DispatchQueue
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) { // 300 วินาที = 5 นาที
            self.isAlertActive = false  // ปลดล็อกให้สามารถแจ้งเตือนอีกครั้ง
            print("5 minutes passed, isAlertActive set to false")
            
            // เรียกใช้งานแจ้งเตือนถัดไป
            self.triggerMoveAlert()  // เริ่มการแจ้งเตือนใหม่
        }
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
