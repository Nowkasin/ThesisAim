//
//  TaskView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 2/2/2568 BE.
//

import SwiftUI

struct TaskView: View {
    @AppStorage("mission") private var mission: String = ""
    @AppStorage("selectedTime") private var selectedTime: Double = 1
    @AppStorage("isTaskStarted") private var isTaskStarted: Bool = false
    @AppStorage("timeRemaining") private var timeRemaining: Double = 0
    @AppStorage("taskStartTime") private var taskStartTime: Double = 0
    @AppStorage("showAlert") private var showAlert: Bool = false

    @State private var timer: Timer? = nil
    @State private var animateBearBounce = false
    @State private var showBadge = false

    let imageUrl: String = "https://i.imgur.com/TR7HwEa.png"

    var body: some View {
        ZStack {
            LinearGradient(colors: [.white, .blue.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture { hideKeyboard() }

            VStack(spacing: 24) {
                Text("🐻 Bear Mate")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.blue)

                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: animateBearBounce ? .yellow.opacity(0.6) : .clear, radius: 20)
                        .scaleEffect(animateBearBounce ? 1.08 : 0.92)
                        .offset(y: animateBearBounce ? -4 : 4)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateBearBounce)
                        .onAppear {
                            animateBearBounce = true
                        }
                } placeholder: {
                    ProgressView()
                }

                VStack(spacing: 12) {
                    Text("What's your mission?")
                        .font(.headline)
                        .foregroundColor(.gray)

                    TextField("Type your goal...", text: $mission)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                        .disabled(isTaskStarted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 4) {
                    Text("Set Timer")
                        .font(.headline)
                        .padding(.top)

                    Slider(value: $selectedTime, in: 1...120, step: 1)
                        .tint(.blue)
                        .padding(.horizontal)

                    Text("\(Int(selectedTime)) minutes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if isTaskStarted {
                    ProgressCircle(timeRemaining: timeRemaining, totalTime: selectedTime * 60)
                        .frame(width: 180, height: 180)
                        .padding(.top, 10)
                }

                Button(action: isTaskStarted ? giveUpTask : startTask) {
                    Text(isTaskStarted ? "Give Up" : "Start")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isTaskStarted ? Color.red : Color.green)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .disabled(mission.isEmpty)

                Spacer()
            }
            .padding()

            if showBadge {
                VStack {
                    Text("✅ Mission Complete!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(12)
                        .background(Color.green.opacity(0.9))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    Spacer()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("🎉 Task Complete"),
                message: Text("Great job!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear { checkIfTaskCompleted() }
    }

    // MARK: - Logic Functions
    func startTask() {
        isTaskStarted = true
        taskStartTime = Date().timeIntervalSince1970
        timeRemaining = selectedTime * 60
        showAlert = false
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

        withAnimation(.easeOut(duration: 0.5)) {
            showBadge = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                showBadge = false
            }
            showAlert = true
        }
    }

    func giveUpTask() {
        timer?.invalidate()
        isTaskStarted = false
        taskStartTime = 0
        timeRemaining = 0
        showAlert = false
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

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Progress Circle
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
        TaskView()
    }
}



