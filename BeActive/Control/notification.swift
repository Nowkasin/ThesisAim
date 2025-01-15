//
//  notification.swift
//  BeActive
//
//  Created by Kasin Thappawan on 28/10/2567 BE.
//

import Foundation
import UserNotifications

class AlertsManager {
    var isWaterAlertActive = false
    var isAlertActive = false

    func triggerWaterAlert() {
            print("Attempting to trigger water alert...")
            if !isWaterAlertActive {
                let content = UNMutableNotificationContent()
                content.title = "ดื่มน้ำได้แล้ว!"
                content.body = "ถึงเวลาดื่มน้ำแล้วนะ!"
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false) // Start immediately
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error triggering water reminder notification: \(error.localizedDescription)")
                    } else {
                        print("Water reminder notification scheduled successfully")
                        self.isWaterAlertActive = true
                        print("isWaterAlertActive set to true")
                        self.scheduleNextWaterAlertAfterDelay() // Schedule the next alert
                    }
                }
            } else {
                print("Water reminder alert is already active, waiting for the next alert.")
            }
        }

        private func scheduleNextWaterAlertAfterDelay() {
            print("Starting 10 minute delay for water reminder")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1800) { // 1800 seconds = 30 minutes
                self.isWaterAlertActive = false
                print("10 minutes passed, isWaterAlertActive set to false")
                self.triggerWaterAlert() // Restart the alert
            }
        }
        
        func triggerMoveAlert() {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3600) { // 3600 วินาที = 1 ชั่วโมง
                self.isAlertActive = false  // ปลดล็อกให้สามารถแจ้งเตือนอีกครั้ง
                print("5 minutes passed, isAlertActive set to false")
                
                // เรียกใช้งานแจ้งเตือนถัดไป
                self.triggerMoveAlert()  // เริ่มการแจ้งเตือนใหม่
            }
        }
}
