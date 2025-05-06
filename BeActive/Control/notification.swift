//
//  notification.swift
//  BeActive
//
//  Created by Kasin Thappawan on 28/10/2567 BE.
//

import Foundation
import UserNotifications

class AlertsManager {
    static let shared = AlertsManager()
    private init() {}
    var isWaterAlertActive = false
    var isAlertActive = false
    private var lastHeartRateAlertTime: Date?
    private var lastInactivityAlertTime: Date?
    var wakeUpTime: DateComponents? // เวลาตื่นที่ user กำหนด
    var bedTime: DateComponents? // เวลานอนที่ user กำหนด
    var intervalHours: Int? // ความถี่ในการแจ้งเตือน

    func setWakeUpAndBedTime(wakeUp: DateComponents?, bed: DateComponents?, interval: Int?) {
        self.wakeUpTime = wakeUp
        self.bedTime = bed
        self.intervalHours = interval
        removeAllNotifications()
        scheduleWaterAlerts()
    }

    public func scheduleWaterAlerts() {
        guard let interval = intervalHours else { return }

        var startHour = wakeUpTime?.hour ?? 8
        let startMinute = wakeUpTime?.minute ?? 0

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
            content.title = t("title", in: "Noti_Screen.WaterNoti")
                   content.body = t("body", in: "Noti_Screen.WaterNoti")
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

        // ถ้า end อยู่ก่อน start → ข้ามวัน (บวก 1 วันให้ end)
        var end = calendar.date(from: DateComponents(hour: endHour, minute: endMinute))!
        if end <= current {
            end = calendar.date(byAdding: .day, value: 1, to: end)!
        }

        while current <= end {
            let components = calendar.dateComponents([.hour, .minute], from: current)
            times.append(components)

            guard let next = calendar.date(byAdding: .hour, value: interval, to: current) else { break }
            current = next
        }

        return times
    }


    public func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications removed.")
    }

    func triggerMoveAlert() {
        if !isAlertActive {
            let content = UNMutableNotificationContent()
            content.title = t("title", in: "Noti_Screen.WalkNoti")
            content.body = t("body", in: "Noti_Screen.WalkNoti")
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
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

        if let lastTime = lastHeartRateAlertTime, Date().timeIntervalSince(lastTime) < 180 {
            print("⏱ Cooldown active — skipping alert.")
            return
        }
        lastHeartRateAlertTime = Date()

        let content = UNMutableNotificationContent()
        content.title = t("title", in: "Noti_Screen.HeartNoti")
        content.body = t("body", in: "Noti_Screen.HeartNoti")
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "heartRateAlert_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error triggering heart rate alert: \(error.localizedDescription)")
            } else {
                print("✅ Heart rate alert (with banner + sound) scheduled immediately")
            }
        }
    }

    func triggerLowHeartRateAlert() {
        print("🚨 Attempting to trigger low heart rate alert...")
        if let lastTime = lastHeartRateAlertTime, Date().timeIntervalSince(lastTime) < 300 {
            print("⏱ Cooldown active — skipping alert.")
            return
        }
        lastHeartRateAlertTime = Date()

        let content = UNMutableNotificationContent()
        content.title = t("title", in: "Noti_Screen.LowHeartNoti")
        content.body = t("body", in: "Noti_Screen.LowHeartNoti")
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "lowHeartRateAlert_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error triggering low heart rate alert: \(error.localizedDescription)")
            } else {
                print("✅ Low heart rate alert scheduled immediately")
            }
        }
    }

    func triggerVeryLowHeartRateAlert() {
        print("🚨 Attempting to trigger very low heart rate alert...")
        if let lastTime = lastHeartRateAlertTime, Date().timeIntervalSince(lastTime) < 90 {
            print("⏱ Cooldown active — skipping alert.")
            return
        }
        lastHeartRateAlertTime = Date()

        let content = UNMutableNotificationContent()
        content.title = t("title", in: "Noti_Screen.VeryLowHeartNoti")
        content.body = t("body", in: "Noti_Screen.VeryLowHeartNoti")
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "veryLowHeartRateAlert_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error triggering very low heart rate alert: \(error.localizedDescription)")
            } else {
                print("✅ Very low heart rate alert scheduled immediately")
            }
        }
    }

    func triggerVeryHighHeartRateAlert() {
        print("🚨 Attempting to trigger very high heart rate alert...")
        if let lastTime = lastHeartRateAlertTime, Date().timeIntervalSince(lastTime) < 90 {
            print("⏱ Cooldown active — skipping alert.")
            return
        }
        lastHeartRateAlertTime = Date()

        let content = UNMutableNotificationContent()
        content.title = t("title", in: "Noti_Screen.VeryHighHeartNoti")
        content.body = t("body", in: "Noti_Screen.VeryHighHeartNoti")
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1.0)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "veryHighHeartRateAlert_\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error triggering very high heart rate alert: \(error.localizedDescription)")
            } else {
                print("✅ Very high heart rate alert scheduled immediately")
            }
        }
    }
    
    // MARK: - Inactivity Alert for Gyro-based Inactivity
    /// Sends an instant notification for inactivity detected by gyro (HealthManager can call this).
    func triggerInactivityAlert() {
        if let lastTime = lastInactivityAlertTime, Date().timeIntervalSince(lastTime) < 3600 { // เวลาที่แจ้งเตือนจะกันไม่ให้มันเบิ้ล
            print("⏱ Cooldown active — skipping inactivity alert.")
            return
        }
        lastInactivityAlertTime = Date()

        let content = UNMutableNotificationContent()
        content.title = t("title", in: "Noti_Screen.InactiveNoti")
        content.body = t("body", in: "Noti_Screen.InactiveNoti")
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "inactivityAlert_\(UUID().uuidString)",
            content: content,
            trigger: nil // Trigger immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending inactivity alert: \(error.localizedDescription)")
            } else {
                print("✅ Inactivity alert sent immediately.")
            }
        }
    }
}
