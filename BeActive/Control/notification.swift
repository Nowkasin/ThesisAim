//
//  notification.swift
//  BeActive
//
//  Created by Kasin Thappawan on 28/10/2567 BE.
//

import Foundation
import UserNotifications
import AudioToolbox


class AlertsManager {
    var isWaterAlertActive = false
    var isAlertActive = false
    var isHeartRateAlertActive = false
    var soundID: SystemSoundID = 1005 // ✅ เก็บ SoundID เพื่อนำไปหยุด   

    func triggerWaterAlert() {
        print("Attempting to trigger water alert...")

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let existingRequests = requests.filter { $0.identifier == "waterReminder" }

            if !existingRequests.isEmpty {
                print("Skipping water alert: Already scheduled.")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "ดื่มน้ำได้แล้ว!"
            content.body = "ถึงเวลาดื่มน้ำแล้วนะ!"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: true)  // ⏳ แจ้งเตือนทุก 30 นาที
            let request = UNNotificationRequest(identifier: "waterReminder", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error triggering water reminder notification: \(error.localizedDescription)")
                } else {
                    print("Water reminder notification scheduled successfully")
                    self.isWaterAlertActive = true
                }
            }
        }
    }

    private func removeOldWaterAlert() {
        // ลบเฉพาะแจ้งเตือนที่แสดงไปแล้ว แต่ไม่ลบแจ้งเตือนที่รอทำงานอยู่
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["waterReminder"])
    }

    private func checkAndScheduleWaterAlert() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let existingRequests = requests.filter { $0.identifier == "waterReminder" }

            if existingRequests.isEmpty {
                self.triggerWaterAlert()  // ถ้ายังไม่มีแจ้งเตือน ให้ตั้งใหม่
            } else {
                print("Water reminder is already scheduled.")
            }
        }
    }


        
        func triggerMoveAlert() {
            if !isAlertActive { // ตรวจสอบว่ามีการแจ้งเตือนอยู่หรือไม่
                let content = UNMutableNotificationContent()
                content.title = "เดินได้แล้ว!"
                content.body = "คุณนั่งนานเกิน 1 ชั่วโมง ลุกขึ้นเดินได้แล้ว!"
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
                print("Alert is already active, waiting for 1 hour.")
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


    func triggerHeartRateAlert() {
        print("🚨 Attempting to trigger heart rate alert...")

        if isHeartRateAlertActive {
            print("⚠️ Heart rate alert is already active, skipping new alert.")
            return
        }

        isHeartRateAlertActive = true

        let content = UNMutableNotificationContent()
        content.title = "🚨 อัตราการเต้นของหัวใจสูง!"
        content.body = "หัวใจของคุณเต้นเร็วเกินไปโดยไม่มีการเคลื่อนไหว โปรดพักหรือตรวจสอบสุขภาพของคุณ"
        
        // ✅ ใช้เสียงแจ้งเตือนที่ดังขึ้น แม้ในโหมดเงียบ
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)
        content.badge = NSNumber(value: 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "heartRateAlert_\(UUID().uuidString)", content: content, trigger: trigger)

        // ✅ ตรวจสอบว่าไม่มีแจ้งเตือนซ้ำ
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let existingRequests = requests.filter { $0.identifier.contains("heartRateAlert") }

            if existingRequests.isEmpty {
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Error triggering heart rate alert: \(error.localizedDescription)")
                    } else {
                        print("✅ Heart rate alert scheduled successfully")
                        self.playSystemAlarm() // ✅ เล่นเสียงทันทีเมื่อแจ้งเตือนขึ้น
                    }
                }
            } else {
                print("⚠️ A similar heart rate alert is already pending, skipping duplicate.")
            }
        }

        scheduleNextHeartRateAlertAfterDelay()
    }

    // ✅ ฟังก์ชันเล่นเสียง 1005 (Alarm)
    func playSystemAlarm() {
        print("🔊 Playing System Sound 1005 (Alarm)")
        AudioServicesPlaySystemSound(soundID) // 🚨 เล่นเสียงแจ้งเตือนทันที
    }

    // ✅ ฟังก์ชันหยุดเสียงเมื่อแจ้งเตือนหยุด
    func stopSystemAlarm() {
        print("🔇 Stopping System Sound 1005 (Alarm)")
        AudioServicesDisposeSystemSoundID(soundID) // 🛑 หยุดเสียง
    }

    // ✅ หยุดเสียงเมื่อแจ้งเตือนหมดเวลา (90 วินาที)
    private func scheduleNextHeartRateAlertAfterDelay() {
        print("⏳ Starting 90-second cooldown for heart rate alert")

        DispatchQueue.main.asyncAfter(deadline: .now() + 90) {
            self.isHeartRateAlertActive = false
            print("✅ 90 seconds passed, isHeartRateAlertActive set to false")

            self.stopSystemAlarm() // 🛑 หยุดเสียงเมื่อครบเวลา
        }
    }

}
