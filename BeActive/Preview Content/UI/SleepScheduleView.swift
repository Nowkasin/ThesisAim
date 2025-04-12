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

    var alertsManager = AlertsManager()
    @Environment(\.presentationMode) var presentationMode

    let storageKey = "savedSleepSchedules"

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Sleep Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(spacing: 16) {
                    timePickerRow(icon: "sunrise.fill", color: .orange, label: "Wake-up", selection: $wakeUpTime)
                    timePickerRow(icon: "moon.fill", color: .purple, label: "Bedtime", selection: $bedTime)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                Button(action: saveSettings) {
                    Text(hasSetSleepSchedule ? "Schedule Saved" : "Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(hasSetSleepSchedule ? Color.gray.opacity(0.4) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                        .padding(.horizontal)
                }
                .disabled(hasSetSleepSchedule)

                if !savedSchedules.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schedule History")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal)

                        List {
                            ForEach(savedSchedules.sorted { $0.savedDate > $1.savedDate }) { schedule in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("⏰ \(formattedTime(hour: schedule.wakeUpHour, minute: schedule.wakeUpMinute)) | 🌙 \(formattedTime(hour: schedule.bedHour, minute: schedule.bedMinute))")
                                        .fontWeight(.medium)
                                    Text("Saved on \(formattedDate(schedule.savedDate))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteHistorySchedule)
                        }
                        .frame(height: 220)
                        .listStyle(PlainListStyle())
                    }
                }

                Spacer()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear(perform: loadSchedules)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    // MARK: - Subview for Time Picker
    func timePickerRow(icon: String, color: Color, label: String, selection: Binding<Date>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Other functions (ไม่เปลี่ยน)
    func saveSettings() {
        guard !hasSetSleepSchedule else {
            print("⚠️ You’ve already set a time. Please delete it before setting a new one.")
            return
        }

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
            wakeUp: DateComponents(hour: wakeUpHour, minute: wakeUpMinute),
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

    func deleteHistorySchedule(at offsets: IndexSet) {
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

    func loadSchedules() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SleepSchedule].self, from: data) {
            savedSchedules = decoded

            if let latest = savedSchedules.sorted(by: { $0.savedDate > $1.savedDate }).first {
                var wakeUp = DateComponents()
                wakeUp.hour = latest.wakeUpHour
                wakeUp.minute = latest.wakeUpMinute

                var bed = DateComponents()
                bed.hour = latest.bedHour
                bed.minute = latest.bedMinute

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

    func saveSchedulesToStorage() {
        if let encoded = try? JSONEncoder().encode(savedSchedules) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func formattedTime(hour: Int, minute: Int) -> String {
        let dateComponents = DateComponents(hour: hour, minute: minute)
        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }

    func formattedDate(_ date: Date) -> String {
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

