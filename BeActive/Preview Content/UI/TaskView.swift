//
//  TaskView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 2/2/2568 BE.
//

import SwiftUI

struct TaskView: View {
    @AppStorage("mission") private var mission: String = ""
    @AppStorage("selectedTime") private var selectedTime: Double = 1 // Time in minutes
    @AppStorage("isTaskStarted") private var isTaskStarted: Bool = false
    @AppStorage("timeRemaining") private var timeRemaining: Double = 0
    @AppStorage("taskStartTime") private var taskStartTime: Double = 0 // Store as timestamp
    @AppStorage("showAlert") private var showAlert: Bool = false // Persist alert state

    @State private var timer: Timer? = nil

    let imageUrl: String = "https://w7.pngwing.com/pngs/453/918/png-transparent-pixel-cat.png"

    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 8) {
                // Title Above Image
                Text("Cat Mate")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                // Display Image from URL
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 150)
                } placeholder: {
                    ProgressView()
                }

                // Mission Label & TextField (Centered)
                VStack(spacing: 4) {
                    Text("Mission")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    ZStack {
                        TextField("", text: $mission, prompt: Text("Enter your mission")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .bold))
                        )
                        .padding(12)
                        .background(Color.yellow.opacity(0.4))
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                        .disabled(isTaskStarted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                    }
                }

                Text("Select Time (Minutes)")
                    .font(.headline)
                    .padding(.top, 5)

                // **Thicker Slider**
                Slider(value: $selectedTime, in: 1...120, step: 1)
                    .accentColor(.blue)
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                    .disabled(isTaskStarted)

                Text("\(Int(selectedTime)) minutes")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isTaskStarted {
                    // Show Countdown Timer with Progress Bar
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 10)
                                .opacity(0.3)
                                .foregroundColor(.gray)

                            Circle()
                                .trim(from: 0.0, to: CGFloat(timeRemaining / (selectedTime * 60)))
                                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: timeRemaining)

                            VStack {
                                Text(formatTime(timeRemaining))
                                    .font(.largeTitle)
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(width: 150, height: 150)
                    }
                    .padding()
                }

                // Button Changes Based on Task State
                Button(action: isTaskStarted ? giveUpTask : startTask) {
                    Text(isTaskStarted ? "Give Up" : "Start")
                        .fontWeight(.bold)
                        .frame(width: 120, height: 40)
                        .background(isTaskStarted ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(mission.isEmpty)
                .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Task Completed 🎉"),
                    message: Text("Your mission is complete!"),
                    dismissButton: .default(Text("OK"), action: {
                        showAlert = false
                    })
                )
            }
            .onAppear {
                checkIfTaskCompleted() // Ensure task status updates when returning
            }
        }
    }

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
        let elapsedTime = Date().timeIntervalSince1970 - taskStartTime
        let remaining = (selectedTime * 60) - elapsedTime

        if remaining > 0 {
            timeRemaining = remaining
        } else {
            completeTask()
        }
    }

    func completeTask() {
        timer?.invalidate()
        timer = nil
        isTaskStarted = false
        taskStartTime = 0
        timeRemaining = 0
        showAlert = true
    }

    func giveUpTask() {
        timer?.invalidate()
        timer = nil
        isTaskStarted = false
        timeRemaining = 0
        taskStartTime = 0
        showAlert = false
    }

    func checkIfTaskCompleted() {
        if isTaskStarted {
            updateTimeRemaining() // Ensure correct time calculation
            if timeRemaining <= 0 {
                completeTask()
            } else {
                startTimer() // Restart the timer if the task is still running
            }
        }
    }

    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}






