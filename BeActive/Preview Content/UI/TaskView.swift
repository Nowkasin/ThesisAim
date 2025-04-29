//
//  TaskView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 2/2/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
import UserNotifications

struct TaskRecord: Identifiable, Codable {
    let id: UUID
    let mission: String
    let mate: String
    let duration: Int
    let completed: Bool
    let timestamp: Date
}

struct TaskView: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @ObservedObject var language = Language.shared
    @AppStorage("lastTaskOpenedDate") private var lastTaskOpenedDate: String?
    @AppStorage("mission") private var mission: String = ""
    @AppStorage("selectedTime") private var selectedTime: Double = 1
    @AppStorage("isTaskStarted") private var isTaskStarted: Bool = false
    @AppStorage("timeRemaining") private var timeRemaining: Double = 0
    @AppStorage("taskStartTime") private var taskStartTime: Double = 0
    @AppStorage("selectedMate") private var selectedMate: String = "Bear"
    @AppStorage("taskHistoryData") private var taskHistoryData: Data = Data()
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("unlockedMatesData") private var unlockedMatesData: Data = Data()
    @AppStorage("taskJustCompleted") private var taskJustCompleted: Bool = false

    @State private var unlockedMates: [String] = ["Bear"]

    @State private var timer: Timer? = nil
    @State private var animateMateBounce = false
    @State private var showBadge = false
    @State private var showMatePicker = false
    @State private var showMissingMissionAlert = false
    @State private var showGaveUpAlert = false
    @State private var showCompletedAlert = false

    @State private var taskHistory: [TaskRecord] = []
    @State private var showTaskHistory = false
    @State private var recordToDelete: TaskRecord? = nil
    @State private var showDeleteAlert = false

    var mateEmoji: String {
        emoji(for: selectedMate)
    }

    var imageUrl: String {
        switch selectedMate {
        case "Cat": return "https://i.imgur.com/5ym20Wl.png"
        case "Happy Cat": return "https://i.imgur.com/0JJOJbK.png"
        case "Lovely Cat": return "https://i.imgur.com/TRIDeEw.png"
            
        case "Bunny": return "https://i.imgur.com/if52U93.png"
        case "Happy Bunny": return "https://i.imgur.com/ZZlNIjX.png"
        case "Lovely Bunny": return "https://i.imgur.com/VLvp9Qm.png"
            
        case "Chick": return "https://i.imgur.com/ay4YRSm.png"
        case "Happy Chick": return "https://i.imgur.com/YBn2oFH.png"
        case "Lovely Chick": return "https://i.imgur.com/YPFM2Bu.png"
            
        case "Dog": return "https://i.imgur.com/RObtJjY.png"
        case "Happy Dog": return "https://i.imgur.com/YiEE02e.png"
        case "Lovely Dog": return "https://i.imgur.com/y3ocZ22.png"
            
        case "Mocha": return "https://i.imgur.com/sY0fdeH.png"
        case "Happy Bear": return "https://i.imgur.com/mTEiOqd.png"
        case "Lovely Bear": return "https://i.imgur.com/OT2vJPe.png"
            
        default: return "https://i.imgur.com/TR7HwEa.png"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("\(mateEmoji) \(selectedMate) Mate")
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 30))                        .foregroundStyle(.blue)

                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: animateMateBounce ? .yellow.opacity(0.6) : .clear, radius: 20)
                        .scaleEffect(animateMateBounce ? 1.08 : 0.92)
                        .offset(y: animateMateBounce ? -4 : 4)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                                animateMateBounce = true
                            }
                        }

                    VStack(spacing: 12) {
                        Text(t("mission_label", in: "Task_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))                            .foregroundColor(.gray)

                        TextField(t("mission_placeholder", in: "Task_screen"), text: $mission)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                            .disabled(isTaskStarted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 4) {
                        Text(t("set_timer", in: "Task_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))                            .padding(.top)

                        Slider(value: $selectedTime, in: 1...120, step: 1)
                            .tint(.blue)
                            .disabled(isTaskStarted)
                            .padding(.horizontal)

                        Text("\(Int(selectedTime)) \(t("minutes_unit", in: "Task_screen"))")
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))                            .foregroundColor(.gray)
                    }

                    if isTaskStarted {
                        ProgressCircle(timeRemaining: timeRemaining, totalTime: selectedTime * 60)
                            .frame(width: 180, height: 180)
                            .padding(.top, 10)
                    }

                    Button(action: {
                        if isTaskStarted {
                            giveUpTask()
                        } else {
                            if mission.isEmpty {
                                showMissingMissionAlert = true
                            } else {
                                startTask()
                            }
                        }
                    }) {
                        Text(isTaskStarted ? t("give_up", in: "Task_screen") : t("start", in: "Task_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isTaskStarted ? Color.red : Color.green)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)

                    Button(t("select_mate", in: "Task_screen")) {
                        showMatePicker = true
                    }
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))                    .foregroundColor(isTaskStarted ? .gray : .blue)
                    .disabled(isTaskStarted)

                    if !taskHistory.isEmpty {
                        Button {
                            withAnimation {
                                showTaskHistory.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text(showTaskHistory ? t("hide_history", in: "Task_screen") : t("show_history", in: "Task_screen"))
                            }
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))                            .foregroundColor(.blue)
                        }
                    }

                    if showTaskHistory {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(taskHistory.reversed()) { record in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))                                            .foregroundColor(.secondary)

                                        Spacer()

                                        Button(role: .destructive) {
                                            recordToDelete = record
                                            showDeleteAlert = true
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }

                                    Text("📝 \(t("mission", in: "Task_screen")): \(record.mission)")
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                    Text("🐾 \(t("mate", in: "Task_screen")): \(emoji(for: record.mate)) \(record.mate)")
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                    Text("⏱ \(t("duration", in: "Task_screen")): \(record.duration) \(t("minutes_unit", in: "Task_screen"))")
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                    Text("📊 \(t("status", in: "Task_screen")): \(record.completed ? t("completed", in: "Task_screen") : t("gave_up", in: "Task_screen"))")
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                Color.clear.frame(height: 80)
            }
            .sheet(isPresented: $showMatePicker) {
                ScrollView {
                    VStack(spacing: 16) {
                        Text(t("choose_mate", in: "Task_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))                            .padding(.top)

                        ForEach(unlockedMates, id: \.self) { mate in
                            Button(action: {
                                selectedMate = mate
                                showMatePicker = false
                            }) {
                                Text("\(emoji(for: mate)) \(mate)")
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 22))                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .alert(t("mission_required_title", in: "Task_screen"), isPresented: $showMissingMissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(t("mission_required_message", in: "Task_screen"))
            }
            .alert(t("gave_up_title", in: "Task_screen"), isPresented: $showGaveUpAlert) {
                Button("OK") { }
            } message: {
                Text(t("gave_up_message", in: "Task_screen"))
            }
            .alert(t("completed_title", in: "Task_screen"), isPresented: $showCompletedAlert) {
                Button("OK") { }
            } message: {
                Text(t("completed_message", in: "Task_screen"))
            }
            .alert(t("delete_title", in: "Task_screen"), isPresented: $showDeleteAlert) {
                Button(t("delete", in: "Task_screen"), role: .destructive) {
                    if let record = recordToDelete {
                        taskHistory.removeAll { $0.id == record.id }
                        saveTaskHistory()
                    }
                }
                Button(t("cancel", in: "Task_screen"), role: .cancel) {
                    recordToDelete = nil
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .onAppear {
                // Set transparent navigation bar appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = .clear
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance

                checkIfTaskCompleted()
                loadTaskHistory()
                loadUnlockedMates()
                checkForNewTaskDay()
                scoreManager.resetTaskScoreIfNewDay()
            }
        }
    }

    func saveUnlockedMatesToStorage(_ mates: [String]) {
        if let data = try? JSONEncoder().encode(mates) {
            unlockedMatesData = data
        }
    }

    func loadUnlockedMatesFromStorage() {
        if let loaded = try? JSONDecoder().decode([String].self, from: unlockedMatesData) {
            unlockedMates = loaded
        }
    }

    func loadUnlockedMates() {
        loadUnlockedMatesFromStorage()

        guard !currentUserId.isEmpty else { return }
        var result: [String] = ["Bear"]

        Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .collection("mates")
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    if doc.data()["unlocked"] as? Bool == true {
                        let mateName = doc.documentID
                        if mateName != "Bear" {
                            result.append(mateName)
                        }
                    }
                }
                let unique = Array(Set(result)).sorted()
                unlockedMates = unique
                saveUnlockedMatesToStorage(unique)
            }
    }

    func startTask() {
        isTaskStarted = true
        taskJustCompleted = false // ✅ Reset to allow scoring
        taskStartTime = Date().timeIntervalSince1970
        timeRemaining = selectedTime * 60
        startTimer()

        // Schedule notification for task end
        let fireDate = Calendar.current.date(byAdding: .second, value: Int(selectedTime * 60), to: Date())!
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: fireDate)

        let content = UNMutableNotificationContent()
        content.title = t("noti_task_completed_title", in: "Noti_Screen")
        content.body = t("noti_task_completed_body", in: "Noti_Screen")
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "task_end_noti", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

//    func startTimer() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            updateTimeRemaining()
//        }
//    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateTimeRemaining()
        }
    }

    func updateTimeRemaining() {
        let elapsed = Date().timeIntervalSince1970 - taskStartTime
        let remaining = (selectedTime * 60) - elapsed
        if remaining > 0 {
            timeRemaining = remaining
        } else {
            completeTask()
        }
    }

    func completeTask() {
        guard !taskJustCompleted else {
            print("⚠️ Task already completed — skipping duplicate.")
            return
        }
        taskJustCompleted = true // ✅ Mark task as rewarded

        timer?.invalidate()
        isTaskStarted = false
        taskStartTime = 0
        timeRemaining = 0

        let record = TaskRecord(
            id: UUID(),
            mission: mission,
            mate: selectedMate,
            duration: Int(selectedTime),
            completed: true,
            timestamp: Date()
        )

        taskHistory.append(record)
        saveTaskHistory()
        scoreManager.addTaskScore(20)


        withAnimation { showBadge = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showBadge = false }
            showCompletedAlert = true
        }
    }

    func giveUpTask() {
        timer?.invalidate()
        isTaskStarted = false
        taskStartTime = 0
        timeRemaining = 0

        // Remove pending notification for task end
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task_end_noti"])

        let record = TaskRecord(
            id: UUID(),
            mission: mission,
            mate: selectedMate,
            duration: Int(selectedTime),
            completed: false,
            timestamp: Date()
        )

        taskHistory.append(record)
        saveTaskHistory()
        scoreManager.addTaskScore(-100)
        showGaveUpAlert = true
    }

//    func checkIfTaskCompleted() {
//        if isTaskStarted {
//            updateTimeRemaining()
//            if timeRemaining <= 0 {
//                completeTask()
//            } else {
//                startTimer()
//            }
//        }
//    }
    
    func checkIfTaskCompleted() {
        guard isTaskStarted else { return }

        // Calculate immediately to avoid stale UI
        let elapsed = Date().timeIntervalSince1970 - taskStartTime
        let remaining = (selectedTime * 60) - elapsed
        timeRemaining = max(remaining, 0)

        if timeRemaining <= 0 {
            completeTask()
        } else {
            startTimer()
        }
    }

    func emoji(for mate: String) -> String {
        switch mate {
        case "Cat": return "🐱"
        case "Happy Cat": return "😸"
        case "Lovely Cat": return "😻"
        case "Bunny": return "🐰"
        case "Happy Bunny": return "🐇"
        case "Lovely Bunny": return "🥕"
        case "Chick": return "🐤"
        case "Happy Chick": return "🐣"
        case "Lovely Chick": return "🐥"
        case "Dog": return "🐶"
        case "Happy Dog": return "🦴"
        case "Lovely Dog": return "🐾"
        case "Mocha": return "🦈"
        case "Happy Bear": return "🐻‍❄️"
        case "Lovely Bear": return "🧸"
        default: return "🐻"
        }
    }

    func saveTaskHistory() {
        if let encoded = try? JSONEncoder().encode(taskHistory) {
            taskHistoryData = encoded
        }
    }

    func loadTaskHistory() {
        if let decoded = try? JSONDecoder().decode([TaskRecord].self, from: taskHistoryData) {
            taskHistory = decoded
        }
    }

    func checkForNewTaskDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        let isNewDay = lastTaskOpenedDate == nil || lastTaskOpenedDate != today
        lastTaskOpenedDate = today

        if isNewDay {
            mission = ""
            selectedTime = 1
            isTaskStarted = false
            timeRemaining = 0
            taskStartTime = 0
            showBadge = false
        }
    }
}

struct ProgressCircle: View {
    var timeRemaining: Double
    var totalTime: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.2)
                .foregroundColor(.blue)

            Circle()
                .trim(from: 0.0, to: CGFloat(timeRemaining / totalTime))
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [.blue, .green]), center: .center),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timeRemaining)

            Text(formatTime(timeRemaining))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)
        }
    }

    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView().environmentObject(ScoreManager.shared)
    }
}
