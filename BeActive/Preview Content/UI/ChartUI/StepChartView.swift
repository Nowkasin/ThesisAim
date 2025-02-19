//
//  StepChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct StepChartView: View {
    let activity: Activity  // ✅ รับค่า Activity
    @StateObject private var viewModel = StepCountViewModel()

    var body: some View {
        List {
            VStack {
                Text(activity.titleKey) // ✅ ใช้ค่าจาก Activity
                    .font(.title)
                    .bold()

                if viewModel.stepCountData.isEmpty {
                    Text("No data available")
                        .foregroundColor(.primary)
                        .transition(.opacity)
                } else {
                    StepCountGraph(data: viewModel.stepCountData)
                        .frame(height: 200)
                        .padding()
                        .transition(.slide)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle(activity.titleKey) // ✅ ใช้ชื่อ Activity เป็น Title
        .onAppear {
            viewModel.fetchWeeklyStepCount()
        }
    }
}

// 🔍 แก้ไข `#Preview` ให้ใช้ Activity จำลอง
#Preview {
    StepChartView(activity: Activity(
        id: 2,
        titleKey: "Daily Steps",
        subtitleKey: "Goal: 10,000 Steps",
        image: "figure.walk",
        tintColor: .green,
        amount: "6,234",
        goalValue: "10,000 Steps"
    ))
}
