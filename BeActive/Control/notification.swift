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
        removeAllWaterAlerts()
        scheduleWaterAlerts()
    }

    // ✅ ตั้งค่าแจ้งเตือนให้รองรับทั้งชั่วโมง และ นาที
    public func scheduleWaterAlerts() {
        let startHour = wakeUpTime?.hour ?? 8
        let startMinute = wakeUpTime?.minute ?? 0
        let endHour = bedTime?.hour ?? 22
        let endMinute = bedTime?.minute ?? 0
        let interval = intervalHours ?? 1

        // ✅ คำนวณช่วงเวลาตามที่ผู้ใช้กำหนด
        let notificationTimes = generateNotificationTimes(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            interval: interval
        )

        for (index, time) in notificationTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "ดื่มน้ำได้แล้ว!"
            content.body = "ถึงเวลาดื่มน้ำแล้วนะ!"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let request = UNNotificationRequest(identifier: "waterReminder_\(index)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling water reminder: \(error.localizedDescription)")
                } else {
                    print("✅ Water reminder scheduled at \(time.hour ?? 0):\(time.minute ?? 0)")
                }
            }
        }
    }

    // ✅ ฟังก์ชันสร้างช่วงเวลาการแจ้งเตือนที่รองรับทั้งชั่วโมง และ นาที
    private func generateNotificationTimes(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, interval: Int) -> [DateComponents] {
        var times: [DateComponents] = []
        var currentHour = startHour
        var currentMinute = startMinute

        while currentHour < endHour || (currentHour == endHour && currentMinute <= endMinute) {
            times.append(DateComponents(hour: currentHour, minute: currentMinute))

            // ✅ อัปเดตเวลาเพิ่มตาม interval ที่กำหนด
            currentHour += interval

            // ✅ ป้องกันไม่ให้เกิน endHour
            if currentHour > endHour || (currentHour == endHour && currentMinute > endMinute) {
                break
            }
        }

        return times
    }

    // ✅ ลบแจ้งเตือนเก่าทั้งหมดเมื่อเปลี่ยนค่า
    private func removeAllWaterAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All water reminders removed.")
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
