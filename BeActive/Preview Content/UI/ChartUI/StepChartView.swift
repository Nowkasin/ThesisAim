//
//  StepChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct StepChartView: View {
    @StateObject var themeManager = ThemeManager() // ✅ ใช้งาน ThemeManager
    let activity: Activity
    @StateObject private var viewModel = StepCountViewModel()
    @State private var selectedRange: TimeRange = .month

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

            // ✅ ข้อมูลสรุปด้านบน
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.averageSteps, specifier: "%.0f") ก้าว")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(themeManager.textColor)
                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.subheadline)
                    .foregroundColor(themeManager.textColor) // ✅ ใช้สีข้อความจาก ThemeManager
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // ✅ กราฟแสดงผล
            StepCountGraph(data: viewModel.filteredData(for: selectedRange))
                .frame(height: 250)
                .padding()

            Spacer()
        }
        .navigationTitle(activity.titleKey)
        .background(themeManager.backgroundColor) // ✅ ตั้งค่าพื้นหลังของหน้าทั้งหมด
        .onAppear {
            viewModel.fetchStepCount(for: selectedRange)
        }
        .onChange(of: selectedRange) { newRange in
            viewModel.fetchStepCount(for: newRange)
        }
    }
}

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
