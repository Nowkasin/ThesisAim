//
//  TaskView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 2/2/2568 BE.
//

import SwiftUI
import FirebaseFirestore

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

    @AppStorage("mission") private var mission: String = ""
    @AppStorage("selectedTime") private var selectedTime: Double = 1
    @AppStorage("isTaskStarted") private var isTaskStarted: Bool = false
    @AppStorage("timeRemaining") private var timeRemaining: Double = 0
    @AppStorage("taskStartTime") private var taskStartTime: Double = 0
    @AppStorage("selectedMate") private var selectedMate: String = "Bear"
    @AppStorage("taskHistoryData") private var taskHistoryData: Data = Data()
    @AppStorage("currentUserId") private var currentUserId: String = ""

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
        case "Bunny": return "https://i.imgur.com/if52U93.png"
        case "Chick": return "https://i.imgur.com/ay4YRSm.png"
        case "Dog": return "https://i.imgur.com/RObtJjY.png"
        case "Mocha": return "https://i.imgur.com/sY0fdeH.png"
        default: return "https://i.imgur.com/TR7HwEa.png"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("\(mateEmoji) \(selectedMate) \(t("your_mate", in: "Task_screen"))")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.blue)

                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: animateMateBounce ? .yellow.opacity(0.6) : .clear, radius: 20)
                            .scaleEffect(animateMateBounce ? 1.08 : 0.92)
                            .offset(y: animateMateBounce ? -4 : 4)
                            .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: animateMateBounce)
                            .onAppear { animateMateBounce = true }
                    } placeholder: {
                        ProgressView()
                    }

                    VStack(spacing: 12) {
                        Text(t("mission_label", in: "Task_screen"))
                            .font(.headline)
                            .foregroundColor(.gray)

                        TextField(t("mission_placeholder", in: "Task_screen"), text: $mission)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                            .disabled(isTaskStarted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 4) {
                        Text(t("set_timer", in: "Task_screen"))
                            .font(.headline)
                            .padding(.top)

                        Slider(value: $selectedTime, in: 1...120, step: 1)
                            .tint(.blue)
                            .disabled(isTaskStarted)
                            .padding(.horizontal)

                        Text("\(Int(selectedTime)) \(t("minutes_unit", in: "Task_screen"))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
                            .font(.headline)
                            .foregroundColor(.white)
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
                    .font(.subheadline)
                    .foregroundColor(isTaskStarted ? .gray : .blue)
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
                            .font(.headline)
                            .foregroundColor(.blue)
                        }
                    }

                    if showTaskHistory {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(taskHistory.reversed()) { record in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Spacer()

                                        Button(role: .destructive) {
                                            recordToDelete = record
                                            showDeleteAlert = true
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }

                                    Text("📝 \(t("mission", in: "Task_screen")): \(record.mission)")
                                    Text("🐾 \(t("mate", in: "Task_screen")): \(emoji(for: record.mate)) \(record.mate)")
                                    Text("⏱ \(t("duration", in: "Task_screen")): \(record.duration) \(t("minutes_unit", in: "Task_screen"))")
                                    Text("📊 \(t("status", in: "Task_screen")): \(record.completed ? t("completed", in: "Task_screen") : t("gave_up", in: "Task_screen"))")
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
            }
            .sheet(isPresented: $showMatePicker) {
                VStack(spacing: 16) {
                    Text(t("choose_mate", in: "Task_screen"))
                        .font(.headline)
                        .padding(.top)

                    ForEach(unlockedMates, id: \.self) { mate in
                        Button(action: {
                            selectedMate = mate
                            showMatePicker = false
                        }) {
                            Text("\(emoji(for: mate)) \(mate)")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }

                    Spacer()
                }
                .padding()
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
                checkIfTaskCompleted()
                loadTaskHistory()
                loadUnlockedMates()
            }
        }
    }

    func loadUnlockedMates() {
        var result: [String] = ["Bear"]
        guard !currentUserId.isEmpty else {
            unlockedMates = result
            return
        }

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
                unlockedMates = Array(Set(result))
            }
    }

    func startTask() {
        isTaskStarted = true
        taskStartTime = Date().timeIntervalSince1970
        timeRemaining = selectedTime * 60
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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

    func checkIfTaskCompleted() {
        if isTaskStarted {
            updateTimeRemaining()
            if timeRemaining <= 0 {
                completeTask()
            } else {
                startTimer()
            }
        }
    }

    func emoji(for mate: String) -> String {
        switch mate {
        case "Cat": return "🐱"
        case "Bunny": return "🐰"
        case "Chick": return "🐤"
        case "Dog": return "🐶"
        case "Mocha": return "🦈"
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
                .animation(.easeInOut(duration: 0.5), value: timeRemaining)

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
