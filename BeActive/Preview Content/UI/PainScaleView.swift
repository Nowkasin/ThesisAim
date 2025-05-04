//
//  PainScaleView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI
import UserNotifications

struct PainRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let values: [String: Int]
}

struct PainScaleView: View {
    @ObservedObject var language = Language.shared

    @State private var headPain: Double = 0
    @State private var neckPain: Double = 0
    @State private var armPain: Double = 0
    @State private var shoulderPain: Double = 0
    @State private var backPain: Double = 0
    @State private var legPain: Double = 0
    @State private var footPain: Double = 0

    @AppStorage("painHistoryData") private var painHistoryData: Data = Data()

    @State private var history: [PainRecord] = []
    @State private var showHistory = false

    @State private var showSaveConfirmation = false
    @State private var showDeleteConfirmation = false

    @State private var showSaveAlert = false
    @State private var recordToDelete: PainRecord?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text(t("Pain Scale", in: "Pain_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 36))
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                Image("PainScale")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)

                painSlider(label: t("Head", in: "Pain_screen"), value: $headPain)
                painSlider(label: t("Neck", in: "Pain_screen"), value: $neckPain)
                painSlider(label: t("Arm", in: "Pain_screen"), value: $armPain)
                painSlider(label: t("Shoulder", in: "Pain_screen"), value: $shoulderPain)
                painSlider(label: t("Back", in: "Pain_screen"), value: $backPain)
                painSlider(label: t("Leg", in: "Pain_screen"), value: $legPain)
                painSlider(label: t("Foot", in: "Pain_screen"), value: $footPain)

                Button(action: {
                    showSaveAlert = true
                }) {
                    Text(t("Save", in: "Pain_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // MARK: - 🔔 Test Notification Button (Comment out to disable)
//                Button(action: {
//                    triggerTestPainNotification()
//                }) {
//                    Text("🔔 Test Notification")
//                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.orange)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)

                if !history.isEmpty {
                    Button(action: {
                        withAnimation {
                            showHistory.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(showHistory ? t("Hide History", in: "Pain_screen") : t("Show History", in: "Pain_screen"))

                        }
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    }
                }

                if showHistory && !history.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(history.reversed()) { record in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Button(role: .destructive) {
                                        recordToDelete = record
                                        showDeleteAlert = true
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }

                                ForEach([
                                    t("Head", in: "Pain_screen"),
                                    t("Neck", in: "Pain_screen"),
                                    t("Arm", in: "Pain_screen"),
                                    t("Shoulder", in: "Pain_screen"),
                                    t("Back", in: "Pain_screen"),
                                    t("Leg", in: "Pain_screen"),
                                    t("Foot", in: "Pain_screen")
                                ], id: \.self) { part in
                                    if let value = record.values[part] {
                                        HStack {
                                            Text("\(part) \(value <= 3 ? "(✅)" : value <= 7 ? "(⚠️)" : "(🚨)")")
                                            Spacer()
                                            Text("\(value)").bold()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(.systemBackground))
        .alert(t("Save Pain Scale?", in: "Pain_screen"), isPresented: $showSaveAlert) {
            Button(t("Save", in: "Pain_screen"), role: .none, action: savePainData)
            Button(t("Cancel", in: "Mate_screen"), role: .cancel) { }
        }

        .alert(t("Delete this record?", in: "Pain_screen"), isPresented: $showDeleteAlert) {
            Button(t("Delete", in: "Pain_screen"), role: .destructive) {
                if let record = recordToDelete {
                    deleteRecord(record)
                }
            }
            Button(t("Cancel", in: "Mate_screen"), role: .cancel) { recordToDelete = nil }
        }

        .overlay(
            VStack(spacing: 10) {
                if showSaveConfirmation {
                    Text(t("Pain Scale Saved!", in: "Pain_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if showDeleteConfirmation {
                    Text(t("Record Deleted", in: "Pain_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 50)
        )
        .animation(.easeInOut, value: showSaveConfirmation || showDeleteConfirmation)
        .onAppear {
            loadHistory()
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

            schedulePainReminder()
        }
    }

    func painSlider(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 20))
                .foregroundColor(.primary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(sliderColor(for: value.wrappedValue))
                        .frame(width: CGFloat(value.wrappedValue / 10) * geometry.size.width, height: 8)

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            LongPressGesture(minimumDuration: 0.3)
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onChanged { gestureValue in
                                    if case .second(true, let drag?) = gestureValue {
                                        let location = drag.location.x
                                        let percent = max(0, min(1, location / geometry.size.width))
                                        value.wrappedValue = round(percent * 10)
                                    }
                                }
                        )
                }
            }
            .frame(height: 30)

            HStack {
                ForEach(0...10, id: \.self) { number in
                    Text("\(number)")
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 11))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }

    func sliderColor(for value: Double) -> Color {
        switch value {
        case 0:
            return .green
        case 1...3:
            return Color.green.opacity(0.8)
        case 4...6:
            return .yellow
        case 7...8:
            return .orange
        default:
            return .red
        }
    }

    func savePainData() {
        let newRecord = PainRecord(
            id: UUID(),
            timestamp: Date(),
            values: [
                t("Head", in: "Pain_screen"): Int(headPain),
                t("Neck", in: "Pain_screen"): Int(neckPain),
                t("Arm", in: "Pain_screen"): Int(armPain),
                t("Shoulder", in: "Pain_screen"): Int(shoulderPain),
                t("Back", in: "Pain_screen"): Int(backPain),
                t("Leg", in: "Pain_screen"): Int(legPain),
                t("Foot", in: "Pain_screen"): Int(footPain)
            ]
        )

        history.append(newRecord)
        saveHistory()
        
        schedulePainReminder()

        withAnimation {
            showSaveConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveConfirmation = false
            }
        }
    }

    func deleteRecord(_ record: PainRecord) {
        history.removeAll { $0.id == record.id }
        saveHistory()
        
        schedulePainReminder()

        withAnimation {
            showDeleteConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showDeleteConfirmation = false
            }
        }
    }

    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            painHistoryData = encoded
        }
    }

    func loadHistory() {
        if let decoded = try? JSONDecoder().decode([PainRecord].self, from: painHistoryData) {
            history = decoded
        }
    }
    
    func schedulePainReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["painReminder"])

        let content = UNMutableNotificationContent()
        if let latest = history.last,
           latest.values.contains(where: { $0.value >= 5 }) {
            content.title = t("PainReminderTitle", in: "Pain_screen")
            content.body = t("PainReminderPain", in: "Pain_screen")
        } else {
            content.title = t("PainReminderTitle", in: "Pain_screen")
            content.body = t("PainReminderNormal", in: "Pain_screen")
        }
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 12
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "painReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

struct PainScaleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PainScaleView().preferredColorScheme(.light)
            PainScaleView().preferredColorScheme(.dark)
        }
    }
}

// MARK: - Test Pain Notification function moved inside PainScaleView
extension PainScaleView {
    func triggerTestPainNotification() {
        let content = UNMutableNotificationContent()
        if let latest = history.last,
           latest.values.contains(where: { $0.value >= 5 }) {
            content.title = t("PainReminderTitle", in: "Pain_screen")
            content.body = t("PainReminderPain", in: "Pain_screen")
        } else {
            content.title = t("PainReminderTitle", in: "Pain_screen")
            content.body = t("PainReminderNormal", in: "Pain_screen")
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "testPainReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
