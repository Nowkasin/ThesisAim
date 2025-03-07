//
//  HeartChart.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct HeartChartView: View {
    @StateObject var themeManager = ThemeManager()  // ✅ ใช้ ThemeManager
    let activity: Activity
    @StateObject private var viewModel = HeartRateViewModel()
    @State private var selectedRange: TimeRange = .today  // ✅ ค่าเริ่มต้นเป็นวันนี้

    var body: some View {
        VStack {
            // ✅ Picker สำหรับเลือกช่วงเวลา
            Picker("ช่วงเวลา", selection: $selectedRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(themeManager.backgroundColor)  // ✅ เปลี่ยนสีพื้นหลัง Picker ตามธีม
            .cornerRadius(8)

            // ✅ ข้อมูลสรุปด้านบน
            VStack(alignment: .leading, spacing: 5) {
                Text("\(Int(viewModel.heartRateRange.min)) - \(Int(viewModel.heartRateRange.max)) BPM")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(themeManager.textColor) // ✅ ใช้สีตามธีม
                Text("Avg: \(Int(viewModel.averageBPM)) BPM")
                    .font(.headline)
                    .foregroundColor(themeManager.textColor.opacity(0.8))
                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.subheadline)
                    .foregroundColor(themeManager.textColor.opacity(0.7)) // ✅ สีอ่อนลง
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // ✅ กราฟแสดงผล
            HeartRateGraph(viewModel: viewModel, timeRange: selectedRange)
                .frame(height: 250)
                .padding()

            Spacer()
        }
        .navigationTitle(activity.titleKey)
        .background(themeManager.backgroundColor) // ✅ เปลี่ยนพื้นหลังของ View ตามธีม
        .onAppear {
            viewModel.fetchHeartRate(for: selectedRange)
        }
        .onChange(of: selectedRange) { newRange in
            viewModel.fetchHeartRate(for: newRange)
        }
    }
}

// ✅ Preview
#Preview {
    HeartChartView(
        activity: Activity(
            id: 1,
            titleKey: "Heart Rate",
            subtitleKey: "74-98 BPM",
            image: "heart.fill",
            tintColor: .red,
            amount: "85 BPM",
            goalValue: "60-100 BPM"
        )
    )
}
