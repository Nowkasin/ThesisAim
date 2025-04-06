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
    var soundID: SystemSoundID = 1005
    var wakeUpTime: DateComponents? // เวลาตื่นที่ user กำหนด
    var bedTime: DateComponents? // เวลานอนที่ user กำหนด
    var intervalHours: Int? // ความถี่ในการแจ้งเตือน

    // ✅ ตั้งค่าเวลาตื่น-นอน (ถ้าผู้ใช้ไม่ตั้งค่า จะใช้ค่าเริ่มต้นค่าเริ่มต้นคือเริ่มตอน 8 โมง จนถึง 4 ทุ่ม)
    func setWakeUpAndBedTime(wakeUp: DateComponents?, bed: DateComponents?, interval: Int?) {
        self.wakeUpTime = wakeUp
        self.bedTime = bed
        self.intervalHours = interval
        removeAllNotifications()
        scheduleWaterAlerts()
    }

    // ✅ ตั้งค่าแจ้งเตือนให้รองรับทั้งชั่วโมง และ นาที
    public func scheduleWaterAlerts() {
        guard let interval = intervalHours else { return }

        var startHour = wakeUpTime?.hour ?? 8
        let startMinute = wakeUpTime?.minute ?? 0

        // ✅ เลื่อนเวลาเริ่มต้นไปอีก 1 ชั่วโมงหลังตื่น
        startHour += 1
        if startHour >= 24 { startHour = startHour % 24 }

        let endHour = bedTime?.hour ?? 22
        let endMinute = bedTime?.minute ?? 0

        let notificationTimes = generateRepeatingTimes(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            interval: interval
        )

        if notificationTimes.isEmpty {
            print("⚠️ ไม่พบช่วงเวลาที่เหมาะสมสำหรับแจ้งเตือน (อาจเป็นเพราะเวลาสิ้นสุดอยู่ก่อนเวลาเริ่มต้น)")
            return
        }

        for (index, time) in notificationTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "ดื่มน้ำได้แล้ว!"
            content.body = "ถึงเวลาดื่มน้ำแล้วนะ!"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let request = UNNotificationRequest(identifier: "waterReminder_\(index)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling water reminder: \(error.localizedDescription)")
                } else {
                    print("✅ Water reminder scheduled at \(time.hour ?? 0):\(String(format: "%02d", time.minute ?? 0))")
                }
            }
        }
    }


    // ✅ ฟังก์ชันสร้างช่วงเวลาการแจ้งเตือนที่รองรับทั้งชั่วโมง และ นาที
    private func generateNotificationTimes(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, interval: Int) -> [DateComponents] {
        var times: [DateComponents] = []

        var current = DateComponents()
        current.hour = startHour
        current.minute = startMinute

        let calendar = Calendar.current

        while true {
            guard let date = calendar.date(from: current) else { break }
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)

            if (hour > endHour) || (hour == endHour && minute > endMinute) {
                break
            }

            times.append(DateComponents(hour: hour, minute: minute))

            // ✅ เพิ่ม interval ชั่วโมง
            if let next = calendar.date(byAdding: .hour, value: interval, to: date) {
                current = calendar.dateComponents([.hour, .minute], from: next)
            } else {
                break
            }
        }

        return times
    }
    
    private func generateRepeatingTimes(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, interval: Int) -> [DateComponents] {
        var times: [DateComponents] = []

        let calendar = Calendar.current
        var current = calendar.date(from: DateComponents(hour: startHour, minute: startMinute))!

        // ถ้า end อยู่ก่อน start → ข้ามวัน
        let end = calendar.date(from: DateComponents(hour: endHour, minute: endMinute))!
        let crossesMidnight = end <= current

        repeat {
            let components = calendar.dateComponents([.hour, .minute], from: current)
            times.append(components)

            guard let next = calendar.date(byAdding: .hour, value: interval, to: current) else { break }
            current = next

            // หยุดเมื่อเวลาถึงรอบถัดไปของ end (พิจารณา cross-day)
            if !crossesMidnight && current > end {
                break
            } else if crossesMidnight {
                let nextHour = calendar.component(.hour, from: current)
                let nextMinute = calendar.component(.minute, from: current)
                if nextHour == endHour && nextMinute > endMinute {
                    break
                }
            }
        } while true

        return times
    }

    // ✅ ลบแจ้งเตือนเก่าทั้งหมดเมื่อเปลี่ยนค่า
    // ใน AlertsManager.swift
    public func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications removed.")
    }

    func triggerMoveAlert() {
        if !isAlertActive {
            let content = UNMutableNotificationContent()
            content.title = "เดินได้แล้ว!"
            content.body = "คุณนั่งนานเกิน 1 ชั่วโมง ลุกขึ้นเดินได้แล้ว!"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true) // ✅ แจ้งเตือนทุก 1 ชั่วโมง
            let request = UNNotificationRequest(identifier: "moveReminder", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error triggering move alert: \(error.localizedDescription)")
                } else {
                    print("Move alert scheduled successfully")
                    self.isAlertActive = true
                }
            }
        } else {
            print("Move alert is already active.")
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
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "heartRateAlert_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error triggering heart rate alert: \(error.localizedDescription)")
            } else {
                print("✅ Heart rate alert scheduled successfully")
                self.playSystemAlarm()
            }
        }

        scheduleNextHeartRateAlertAfterDelay()
    }

    func playSystemAlarm() {
        print("🔊 Playing System Sound 1005 (Alarm)")
        AudioServicesPlaySystemSound(soundID)
    }

    func stopSystemAlarm() {
        print("🔇 Stopping System Sound 1005 (Alarm)")
        AudioServicesDisposeSystemSoundID(soundID)
    }

    private func scheduleNextHeartRateAlertAfterDelay() {
        print("⏳ Starting 90-second cooldown for heart rate alert")

        DispatchQueue.main.asyncAfter(deadline: .now() + 90) {
            self.isHeartRateAlertActive = false
            print("✅ 90 seconds passed, isHeartRateAlertActive set to false")
            self.stopSystemAlarm()
        }
    }
}
