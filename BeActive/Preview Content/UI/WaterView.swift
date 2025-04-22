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
    @ObservedObject var language = Language.shared
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
                            Text(t("Water to Drink", in: "Water_screen"))
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 34))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text(t("Don't forget to drink water!", in: "Water_screen"))
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
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
                                Text("\(waterIntake) / \(totalWaterIntake) \(t("ml", in: "Water_screen"))")
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
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
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(item.amount) \(t("ml", in: "Water_screen"))")
                                        .foregroundColor(.gray)
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
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
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                                    .fontWeight(.medium)
                                Text(t("Customize Schedule", in: "Water_screen"))
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                                    .fontWeight(.medium)
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
//                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
//                                .fontWeight(.bold)
//                                .padding()
//                                .frame(width: 200)
//                                .background(.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
                        .padding(.bottom)
                    }
                        Color.clear.frame(height: 5)
                    
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
                        title:
                            Text(t("Congratulations!", in: "Water_screen"))
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 28))
                                .fontWeight(.bold),
                        message: Text(t("You have completed your daily water schedule!", in: "Water_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17)),
                        dismissButton: .default(
                            Text(t("OK", in: "home_screen"))
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                        )
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
                scoreManager.addWaterScore(100)
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
    @ObservedObject var language = Language.shared
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
                Section(header: Text(t("Total Water Intake", in: "Water_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                ) {
                    Text("\(totalIntake) \(t("ml", in: "Water_screen"))")
                        .foregroundColor(.gray)
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                }

                Section(header: Text(t("Add Time Slot", in: "Water_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                ) {
                    DatePicker(t("Time", in: "Water_screen"), selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())

                    Picker(t("Amount", in: "Water_screen"), selection: $selectedAmount) {
                        ForEach(Array(stride(from: 100, through: 1000, by: 50)), id: \.self) { amount in
                            Text("\(amount) \(t("ml", in: "Water_screen"))")
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                                .tag(amount)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)

                    Button(t("Add Slot", in: "Water_screen")) {
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
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                }

                Section(header: Text(t("Your Time Slots", in: "Water_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                ) {
                    if schedule.isEmpty {
                        Text(t("No slots added.", in: "Water_screen"))
                            .foregroundColor(.gray)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    } else {
                        ForEach(schedule) { item in
                            HStack {
                                Text(item.time)
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                                Spacer()
                                Text("\(item.amount) \(t("ml", in: "Water_screen"))")
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
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
            .navigationTitle(
                Text(t("Customize Schedule", in: "Water_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 28))
                    .fontWeight(.bold)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("Done", in: "Water_screen")) {
                        onSave()
                        dismiss()
                    }
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
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
