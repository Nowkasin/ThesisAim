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


// Simulate New Day
import SwiftUI

struct ScheduleItem: Codable, Identifiable {
    let id = UUID() // Unique identifier for each item
    let time: String
    let amount: Int
    var completed: Bool
}

struct WaterView: View {
    @AppStorage("waterIntake") private var waterIntake = 0 // Persist water intake
    @AppStorage("scheduleData") private var scheduleData: Data? // Persist schedule as Data
    @AppStorage("lastOpenedDate") private var lastOpenedDate: String? // Persist last opened date

    @EnvironmentObject var healthManager: HealthManager // Use HealthManager to update water score

    private let totalWaterIntake = 2100 // Total daily goal
    @State private var schedule: [ScheduleItem] = [
        ScheduleItem(time: "09:30", amount: 500, completed: false),
        ScheduleItem(time: "11:30", amount: 500, completed: false),
        ScheduleItem(time: "13:30", amount: 500, completed: false),
        ScheduleItem(time: "15:30", amount: 500, completed: false),
        ScheduleItem(time: "17:30", amount: 100, completed: false),
    ]
    @State private var showCongratulations = false // State for popup visibility

    init() {
        checkForNewDay()
        loadSchedule()
    }

    var body: some View {
        NavigationView {
            VStack {
                // Header Section
                VStack(spacing: 8) {
                    Text("Water to Drink")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.blue)

                    Text("Don't forget to drink water!")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical)

                Spacer()

                // Water Level Section
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
                        Text("\(waterIntake) / \(totalWaterIntake)")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)

                        Image(systemName: "drop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 200, height: 200)

                Spacer()

                // Water Schedule Section
                VStack(alignment: .leading) {
                    ForEach(schedule) { item in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text(item.time)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)

                            Spacer()

                            Text("\(item.amount) ml")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))

                            Button(action: {
                                toggleCompletion(for: item)
                            }) {
                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(item.completed ? .green : .gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()

                Spacer()

                // Simulate New Day Button
                Button(action: simulateNewDay) {
                    Text("Simulate New Day")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .alert(isPresented: $showCongratulations) {
                Alert(
                    title: Text("Congratulations!"),
                    message: Text("You have completed your daily water schedule!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarHidden(true)
        }
    }

    private func toggleCompletion(for item: ScheduleItem) {
        if let index = schedule.firstIndex(where: { $0.id == item.id }) {
            if !schedule[index].completed && waterIntake + schedule[index].amount <= totalWaterIntake {
                schedule[index].completed = true
                waterIntake += schedule[index].amount
            } else if schedule[index].completed {
                schedule[index].completed = false
                waterIntake -= schedule[index].amount
            }
            saveSchedule()

            // Check if all checkmarks are selected
            if schedule.allSatisfy({ $0.completed }) {
                showCongratulations = true
                healthManager.waterScore += 10 // Increase water score by 10 in HealthManager
            }
        }
    }

    private func saveSchedule() {
        do {
            let encodedSchedule = try JSONEncoder().encode(schedule)
            scheduleData = encodedSchedule
        } catch {
            print("Failed to save schedule: \(error)")
        }
    }

    private func loadSchedule() {
        guard let savedData = scheduleData else { return }
        do {
            let decodedSchedule = try JSONDecoder().decode([ScheduleItem].self, from: savedData)
            schedule = decodedSchedule
        } catch {
            print("Failed to load schedule: \(error)")
        }
    }

    private func checkForNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        if lastOpenedDate != today {
            waterIntake = 0
            schedule = schedule.map { ScheduleItem(time: $0.time, amount: $0.amount, completed: false) }
            saveSchedule()
            lastOpenedDate = today
        }
    }

    private func simulateNewDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        lastOpenedDate = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        healthManager.waterScore = 0
        print("Water score reset to 0 for the new day.")
        checkForNewDay()
    }
}

#Preview {
    WaterView()
        .environmentObject(HealthManager()) // Pass HealthManager as environment object
}
