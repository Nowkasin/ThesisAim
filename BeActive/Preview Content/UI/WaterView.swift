//
//  WaterView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 4/11/2567 BE.
//

//import SwiftUI
//
//// Custom struct for schedule items
//struct ScheduleItem: Codable, Identifiable {
//    let id = UUID() // Unique identifier for each item
//    let time: String
//    let amount: Int
//    var completed: Bool
//}
//
//struct WaterView: View {
//    @AppStorage("waterIntake") private var waterIntake = 0 // Persist water intake
//    @AppStorage("scheduleData") private var scheduleData: Data? // Persist schedule as Data
//
//    private let totalWaterIntake = 2100 // Total daily goal
//    @State private var schedule: [ScheduleItem] = [
//        ScheduleItem(time: "09:30", amount: 500, completed: false),
//        ScheduleItem(time: "11:30", amount: 500, completed: false),
//        ScheduleItem(time: "13:30", amount: 500, completed: false),
//        ScheduleItem(time: "15:30", amount: 500, completed: false),
//        ScheduleItem(time: "17:30", amount: 100, completed: false),
//    ]
//    @State private var showCongratulations = false // State for popup visibility
//
//    init() {
//        loadSchedule()
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Header Section
//                VStack(spacing: 8) {
//                    Text("Water to Drink")
//                        .font(.system(size: 34, weight: .bold))
//                        .foregroundColor(.blue)
//
//                    Text("Don't forget to drink water!")
//                        .font(.system(size: 18))
//                        .foregroundColor(.gray)
//                }
//                .multilineTextAlignment(.center)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical)
//
//                Spacer()
//
//                // Water Level Section
//                ZStack {
//                    Circle()
//                        .stroke(lineWidth: 10)
//                        .foregroundColor(.blue.opacity(0.3))
//
//                    Circle()
//                        .trim(from: 0.0, to: CGFloat(Double(waterIntake) / Double(totalWaterIntake)))
//                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
//                        .foregroundColor(.blue)
//                        .rotationEffect(.degrees(-90))
//                        .animation(.easeInOut, value: waterIntake)
//
//                    VStack {
//                        Text("\(waterIntake) / \(totalWaterIntake)")
//                            .font(.system(size: 18))
//                            .fontWeight(.semibold)
//
//                        Image(systemName: "drop.circle.fill")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.blue)
//                    }
//                }
//                .frame(width: 200, height: 200)
//
//                Spacer()
//
//                // Water Schedule Section
//                VStack(alignment: .leading) {
//                    ForEach(schedule) { item in
//                        HStack {
//                            Image(systemName: "clock.fill")
//                                .foregroundColor(.blue)
//                            Text(item.time)
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundColor(.black)
//
//                            Spacer()
//
//                            Text("\(item.amount) ml")
//                                .foregroundColor(.gray)
//                                .font(.system(size: 16))
//
//                            Button(action: {
//                                toggleCompletion(for: item)
//
//                                // Check if all checkmarks are selected
//                                if schedule.filter({ $0.completed }).count == schedule.count {
//                                    showCongratulations = true
//                                }
//                            }) {
//                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(item.completed ? .green : .gray)
//                            }
//                        }
//                        .padding(.vertical, 5)
//                    }
//                }
//                .padding()
//
//                Spacer()
//            }
//            .padding()
//            .alert(isPresented: $showCongratulations) {
//                Alert(
//                    title: Text("Congratulations!"),
//                    message: Text("You have completed your daily water schedule!"),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//            .navigationBarHidden(true)
//        }
//    }
//
//    private func toggleCompletion(for item: ScheduleItem) {
//        if let index = schedule.firstIndex(where: { $0.id == item.id }) {
//            schedule[index].completed.toggle()
//            if schedule[index].completed {
//                waterIntake += schedule[index].amount
//            } else {
//                waterIntake -= schedule[index].amount
//            }
//            saveSchedule()
//        }
//    }
//
//    private func saveSchedule() {
//        do {
//            let encodedSchedule = try JSONEncoder().encode(schedule)
//            scheduleData = encodedSchedule
//        } catch {
//            print("Failed to save schedule: \(error)")
//        }
//    }
//
//    private func loadSchedule() {
//        guard let savedData = scheduleData else { return }
//        do {
//            let decodedSchedule = try JSONDecoder().decode([ScheduleItem].self, from: savedData)
//            schedule = decodedSchedule
//        } catch {
//            print("Failed to load schedule: \(error)")
//        }
//    }
//}
//
//#Preview {
//    WaterView()
//}


import SwiftUI

struct ScheduleItem: Codable, Identifiable {
    let id = UUID()
    var time: String
    var amount: Int
    var completed: Bool
}

struct WaterView: View {
    @AppStorage("waterIntake") private var waterIntake = 0
    @AppStorage("scheduleData") private var scheduleData: Data?
    @AppStorage("lastOpenedDate") private var lastOpenedDate: String?
    @AppStorage("totalWaterIntake") private var storedTotalIntake: Int = 2100
    @AppStorage("scoreGivenToday") private var scoreGivenToday: Bool = false

    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var scoreManager: ScoreManager

    @State private var schedule: [ScheduleItem] = []
    @State private var customTotalIntake: Int = 2100
    @State private var showCongratulations = false
    @State private var showingPopup = false

    @State private var selectedTime = Date()
    @State private var selectedAmount = 250

    private var totalWaterIntake: Int { customTotalIntake }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack {
                        VStack(spacing: 16) {
                            Text("Water to Drink")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.blue)

                            Text("Don't forget to drink water!")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top)

                        ZStack {
                            Circle()
                                .stroke(lineWidth: 10)
                                .foregroundColor(.blue.opacity(0.3))

                            Circle()
                                .trim(from: 0.0, to: CGFloat(Double(waterIntake) / Double(totalWaterIntake)))
                                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: waterIntake)

                            VStack {
                                Text("\(waterIntake) / \(totalWaterIntake) ml")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Image(systemName: "drop.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 200, height: 200)
                        .padding()

                        VStack(spacing: 12) {
                            ForEach(schedule) { item in
                                HStack {
                                    Text(item.time)
                                        .font(.system(size: 18, weight: .medium))
                                    Spacer()
                                    Text("\(item.amount) ml")
                                        .foregroundColor(.gray)
                                    Button(action: {
                                        toggleCompletion(for: item)
                                    }) {
                                        Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.completed ? .green : .gray)
                                    }
                                    .disabled(scoreGivenToday)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)

                        Button(action: {
                            showingPopup = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Customize Schedule")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }

                        // Simulate New Day (commented for production)
//                        Button(action: simulateNewDay) {
//                            Text("Simulate New Day")
//                                .font(.headline)
//                                .padding()
//                                .frame(width: 200)
//                                .background(.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
                        .padding(.bottom)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .sheet(isPresented: $showingPopup) {
                    ScheduleSettingsSheet(
                        schedule: $schedule,
                        totalIntake: $customTotalIntake,
                        selectedTime: $selectedTime,
                        selectedAmount: $selectedAmount,
                        waterIntake: $waterIntake,
                        onSave: {
                            sortScheduleByTime()
                            saveSchedule()
                            storedTotalIntake = customTotalIntake
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
                .onAppear {
                    customTotalIntake = storedTotalIntake
                    checkForNewDay()
                }
                .alert(isPresented: $showCongratulations) {
                    Alert(
                        title: Text("Congratulations!"),
                        message: Text("You have completed your daily water schedule!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    private func toggleCompletion(for item: ScheduleItem) {
        guard !scoreGivenToday else { return }

        if let index = schedule.firstIndex(where: { $0.id == item.id }) {
            if !schedule[index].completed && waterIntake + schedule[index].amount <= totalWaterIntake {
                schedule[index].completed = true
                waterIntake += schedule[index].amount
            } else if schedule[index].completed {
                schedule[index].completed = false
                waterIntake -= schedule[index].amount
            }

            saveSchedule()

            if schedule.allSatisfy({ $0.completed }) && !scoreGivenToday {
                showCongratulations = true
                scoreManager.addWaterScore(10)
                scoreGivenToday = true
            }
        }
    }

    private func saveSchedule() {
        do {
            let encoded = try JSONEncoder().encode(schedule)
            scheduleData = encoded
        } catch {
            print("❌ Failed to save schedule: \(error)")
        }
    }

    private func loadSchedule() {
        guard let data = scheduleData else {
            loadDefaultSchedule()
            return
        }

        do {
            let decoded = try JSONDecoder().decode([ScheduleItem].self, from: data)

            // ✅ Fix: If decode succeeds but schedule is empty
            if decoded.isEmpty {
                loadDefaultSchedule()
            } else {
                schedule = decoded
                sortScheduleByTime()
            }
        } catch {
            print("❌ Failed to decode schedule: \(error)")
            loadDefaultSchedule()
        }
    }
    private func sortScheduleByTime() {
        schedule.sort { $0.time < $1.time }
    }

    private func checkForNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        let isNewDay = lastOpenedDate == nil || lastOpenedDate != today
        lastOpenedDate = today

        if isNewDay {
            waterIntake = 0
            scoreGivenToday = false

            if scheduleData == nil {
                loadDefaultSchedule()
            } else {
                loadSchedule()
            }

            schedule = schedule.map {
                ScheduleItem(time: $0.time, amount: $0.amount, completed: false)
            }

            saveSchedule()
        } else {
            loadSchedule()
        }
    }

    private func loadDefaultSchedule() {
        schedule = [
            ScheduleItem(time: "09:30", amount: 500, completed: false),
            ScheduleItem(time: "11:30", amount: 500, completed: false),
            ScheduleItem(time: "13:30", amount: 500, completed: false),
            ScheduleItem(time: "15:30", amount: 500, completed: false),
            ScheduleItem(time: "17:30", amount: 100, completed: false)
        ]
        customTotalIntake = 2100
        storedTotalIntake = 2100
        saveSchedule()
    }

    private func simulateNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        lastOpenedDate = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        healthManager.waterScore = 0
        checkForNewDay()
    }
}

struct ScheduleSettingsSheet: View {
    @Binding var schedule: [ScheduleItem]
    @Binding var totalIntake: Int
    @Binding var selectedTime: Date
    @Binding var selectedAmount: Int
    @Binding var waterIntake: Int
    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Total Water Intake")) {
                    Text("\(totalIntake) ml")
                        .foregroundColor(.gray)
                }

                Section(header: Text("Add Time Slot")) {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())

                    Picker("Amount", selection: $selectedAmount) {
                        ForEach(Array(stride(from: 100, through: 1000, by: 50)), id: \.self) { amount in
                            Text("\(amount) ml").tag(amount)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)

                    Button("Add Slot") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        let newItem = ScheduleItem(
                            time: formatter.string(from: selectedTime),
                            amount: selectedAmount,
                            completed: false
                        )
                        schedule.append(newItem)
                        totalIntake += selectedAmount
                        schedule.sort { $0.time < $1.time }
                        onSave()
                    }
                }

                Section(header: Text("Your Time Slots")) {
                    if schedule.isEmpty {
                        Text("No slots added.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(schedule) { item in
                            HStack {
                                Text(item.time)
                                Spacer()
                                Text("\(item.amount) ml")
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let item = schedule[index]
                                totalIntake -= item.amount
                                if item.completed {
                                    waterIntake -= item.amount
                                }
                            }
                            schedule.remove(atOffsets: indexSet)
                            schedule.sort { $0.time < $1.time }
                            onSave()
                        }
                    }
                }
            }
            .navigationTitle("Customize Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WaterView()
        .environmentObject(ScoreManager.shared)
        .environmentObject(HealthManager())
}
