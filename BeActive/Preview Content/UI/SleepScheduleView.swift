//
//  SleepScheduleView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/3/2568 BE.
//

import SwiftUI

struct SleepSchedule: Identifiable, Codable {
    let id = UUID()
    let wakeUpHour: Int
    let wakeUpMinute: Int
    let bedHour: Int
    let bedMinute: Int
    let savedDate: Date
}

struct SleepScheduleView: View {
    @State private var wakeUpTime = Date()
    @State private var bedTime = Date()

    @AppStorage("hasSetSleepSchedule") private var hasSetSleepSchedule = false
    @AppStorage("wakeUpHour") private var wakeUpHour = 8
    @AppStorage("wakeUpMinute") private var wakeUpMinute = 0
    @AppStorage("bedHour") private var bedHour = 22
    @AppStorage("bedMinute") private var bedMinute = 0
    @AppStorage("hasCustomBedTime") private var hasCustomBedTime = false

    @State private var savedSchedules: [SleepSchedule] = []

    let alertsManager = AlertsManager()
    @Environment(\.presentationMode) private var presentationMode

    private let storageKey = "savedSleepSchedules"

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("ตั้งค่าเวลาตื่น & เวลานอน")
                    .font(.title)
                    .bold()
                    .padding(.top)

                scheduleForm
                saveButton
                historyList

                Spacer()
            }
            .onAppear(perform: loadSchedules)
            .background(Color(.systemGroupedBackground))
            .navigationBarItems(
                leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            )
        }
    }

    private var scheduleForm: some View {
        Form {
            Section(header: Text("⏰ เวลาตื่น").font(.headline)) {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                    DatePicker("เลือกเวลาตื่น", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
            Section(header: Text("🌙 เวลานอน").font(.headline)) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.purple)
                    DatePicker("เลือกเวลานอน", selection: $bedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
        }
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var saveButton: some View {
        Button(action: {
            if hasSetSleepSchedule {
                print("⚠️ ผู้ใช้ต้องลบเวลาที่ตั้งไว้ก่อน ถึงจะสามารถตั้งใหม่ได้")
            } else {
                saveSettings()
            }
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("บันทึก")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(hasSetSleepSchedule ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .disabled(hasSetSleepSchedule)
    }

    private var historyList: some View {
        Group {
            if !savedSchedules.isEmpty {
                List {
                    Section(header: Text("📝 ประวัติการตั้งเวลา")) {
                        ForEach(savedSchedules.sorted(by: { $0.savedDate > $1.savedDate })) { schedule in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("⏰ \(formattedTime(hour: schedule.wakeUpHour, minute: schedule.wakeUpMinute)) | 🌙 \(formattedTime(hour: schedule.bedHour, minute: schedule.bedMinute))")
                                Text("บันทึกเมื่อ \(formattedDate(schedule.savedDate))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteHistorySchedule)
                    }
                }
                .frame(height: 250)
            }
        }
    }

    private func saveSettings() {
        let calendar = Calendar.current
        let wakeUpComponents = calendar.dateComponents([.hour, .minute], from: wakeUpTime)
        let bedTimeComponents = calendar.dateComponents([.hour, .minute], from: bedTime)

        guard let wakeHour = wakeUpComponents.hour,
              let wakeMinute = wakeUpComponents.minute,
              let bedHourVal = bedTimeComponents.hour,
              let bedMinuteVal = bedTimeComponents.minute else { return }

        wakeUpHour = wakeHour
        wakeUpMinute = wakeMinute
        bedHour = bedHourVal
        bedMinute = bedMinuteVal
        hasCustomBedTime = true
        hasSetSleepSchedule = true

        alertsManager.setWakeUpAndBedTime(
            wakeUp: DateComponents(hour: wakeUpHour + 1, minute: wakeUpMinute),
            bed: DateComponents(hour: bedHour, minute: bedMinute),
            interval: 1
        )

        let newSchedule = SleepSchedule(
            wakeUpHour: wakeHour,
            wakeUpMinute: wakeMinute,
            bedHour: bedHourVal,
            bedMinute: bedMinuteVal,
            savedDate: Date()
        )

        savedSchedules.append(newSchedule)
        saveSchedulesToStorage()

        print("✅ ตั้งค่าใหม่: ตื่น \(wakeHour):\(wakeMinute), นอน \(bedHourVal):\(bedMinuteVal)")

        presentationMode.wrappedValue.dismiss()
    }

    private func deleteHistorySchedule(at offsets: IndexSet) {
        savedSchedules.remove(atOffsets: offsets)
        saveSchedulesToStorage()

        if savedSchedules.isEmpty {
            hasSetSleepSchedule = false
            hasCustomBedTime = false
            wakeUpHour = 8
            wakeUpMinute = 0
            bedHour = 22
            bedMinute = 0

            alertsManager.setWakeUpAndBedTime(
                wakeUp: DateComponents(hour: 8, minute: 0),
                bed: DateComponents(hour: 22, minute: 0),
                interval: 1
            )

            print("🟡 [DEFAULT MODE] ไม่มีการตั้งเวลา → กลับไปใช้ default 08:00–22:00")
        }
    }

    private func loadSchedules() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SleepSchedule].self, from: data) {
            savedSchedules = decoded

            if let latest = savedSchedules.sorted(by: { $0.savedDate > $1.savedDate }).first {
                let wakeUp = DateComponents(hour: latest.wakeUpHour, minute: latest.wakeUpMinute)
                let bed = DateComponents(hour: latest.bedHour, minute: latest.bedMinute)

                alertsManager.setWakeUpAndBedTime(
                    wakeUp: wakeUp,
                    bed: bed,
                    interval: 1
                )

                print("🟢 [USER MODE] ใช้เวลาที่ตั้งไว้ล่าสุด: ตื่น \(latest.wakeUpHour):\(latest.wakeUpMinute), นอน \(latest.bedHour):\(latest.bedMinute)")
            }
        } else {
            print("🟡 [DEFAULT MODE] ยังไม่เคยตั้งเวลา → ใช้ค่าระบบ 08:00–22:00")
            alertsManager.setWakeUpAndBedTime(
                wakeUp: DateComponents(hour: 8, minute: 0),
                bed: DateComponents(hour: 22, minute: 0),
                interval: 1
            )
        }
    }

    private func saveSchedulesToStorage() {
        if let encoded = try? JSONEncoder().encode(savedSchedules) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func formattedTime(hour: Int, minute: Int) -> String {
        let calendar = Calendar.current
        let dateComponents = DateComponents(hour: hour, minute: minute)
        guard let date = calendar.date(from: dateComponents) else {
            return "\(hour):\(String(format: "%02d", minute))"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SleepScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        SleepScheduleView()
    }
}
