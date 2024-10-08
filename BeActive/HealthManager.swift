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
    private var timer: AnyCancellable?
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
        timer = Timer.publish(every: 30, on: .main, in: .common) // Change to 30 seconds
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
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, error in
                if let error = error {
                    print("Error observing \(type.identifier): \(error.localizedDescription)")
                    return
                }
                
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
                
                completionHandler()
            }
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
                    
                    if elapsedTime >= 300 && self?.alertActive == false { // 5 minutes
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
            let distanceInKm = distanceInMeters / 1000
            let activity = Activity(id: 3, title: "Today's Distance", subtitle: "Goal 5 km", image: "figure.walk.circle", tintColor: .blue, amount: distanceInKm.formattedString())
            
            DispatchQueue.main.async {
                self?.activities["dayDistance"] = activity
            }
        }
        healthStore.execute(query)
    }
    
    
    private func triggerMoveAlert() {
           DispatchQueue.main.async {
               print("Triggering alert")
               self.alertMessage = "Your heart rate has been in the target range for 5 minutes. Time to move!"
               self.showAlert = true
               self.alertActive = true // Set alert to active
               NotificationCenter.default.post(name: .moveAlert, object: self.alertMessage)
           }
       }

       func handleAlertDismiss() {
           DispatchQueue.main.async {
               self.alertActive = false // Alert is no longer active
               self.startTime = nil // Reset the timer now that the alert is dismissed
               print("Alert dismissed, resetting timer.")
           }
       }
}
