//
//  HeartChart.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct HeartChartView: View {
    let activity: Activity  // ✅ รับค่า Activity
    @StateObject private var viewModel = HeartRateViewModel()

    var body: some View {
        List {
            VStack {
                Text(activity.titleKey)
                    .font(.title)
                    .bold()

                // ✅ กราฟจะแสดงแม้ว่าจะไม่มีข้อมูลจริง โดยใช้ Placeholder Data
                HeartRateGraph(data: viewModel.heartRateData.isEmpty ? HeartChartView.placeholderData : viewModel.heartRateData)
                    .frame(height: 200)
                    .padding()
                    .transition(.slide)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Today Heart Rate")
        .onAppear {
            print("✅ HeartChartView appeared! Fetching heart rate data...")
            viewModel.fetchTodayHeartRate()
            print("📊 Current heartRateData: \(viewModel.heartRateData)")
        }
    }
    
    // ✅ Placeholder Data กรณียังไม่มีข้อมูลจริง
    static let placeholderData: [(time: Date, bpm: Double)] = [
        (time: Calendar.current.date(byAdding: .minute, value: -30, to: Date())!, bpm: 0),
        (time: Calendar.current.date(byAdding: .minute, value: -20, to: Date())!, bpm: 0),
        (time: Calendar.current.date(byAdding: .minute, value: -10, to: Date())!, bpm: 0),
        (time: Date(), bpm: 0)
    ]
}

// 🔍 Preview
#Preview {
    HeartChartView(activity: Activity(
        id: 1,
        titleKey: "Today Heart Rate",
        subtitleKey: "74-98 BPM",
        image: "heart.fill",
        tintColor: .red,
        amount: "85 BPM",
        goalValue: "60-100 BPM"
    ))
}
