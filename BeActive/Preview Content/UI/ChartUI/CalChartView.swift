//
//  CalChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//


import SwiftUI
import Charts

struct CalChartView: View {
    @StateObject var themeManager = ThemeManager()  // ✅ ใช้ ThemeManager
    let activity: Activity
    @StateObject private var viewModel = CalorieViewModel()
    @State private var selectedRange: TimeRange = .today

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
                Text("\(viewModel.averageCalories, specifier: "%.0f") kcal")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(themeManager.textColor) // ✅ ใช้สีตามธีม
                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.subheadline)
                    .foregroundColor(themeManager.textColor.opacity(0.7)) // ✅ สีอ่อนลง
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // ✅ กราฟแสดงผล
            CalGraph(data: viewModel.filteredData(for: selectedRange), timeRange: selectedRange)
                .frame(height: 250)
                .padding()

            Spacer()
        }
        .navigationTitle(activity.titleKey)
        .background(themeManager.backgroundColor) // ✅ เปลี่ยนพื้นหลังของ View ตามธีม
        .onAppear {
            viewModel.fetchCalories(for: selectedRange)
        }
        .onChange(of: selectedRange) { newRange in
            viewModel.fetchCalories(for: newRange)
        }
    }

    // ✅ Placeholder Data (ถ้ายังไม่มีข้อมูลจริง)
    static let placeholderData: [CalorieData] = [
        CalorieData(time: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, calories: 0),
        CalorieData(time: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, calories: 0),
        CalorieData(time: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, calories: 0),
        CalorieData(time: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, calories: 0),
        CalorieData(time: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, calories: 0),
        CalorieData(time: Date(), calories: 0)
    ]
}

// 🔍 Preview ใช้ Activity จำลอง และต้องสร้าง ViewModel เพื่อส่งเข้าไป
#Preview {
    CalChartView(
        activity: Activity(
            id: 3,
            titleKey: "Calories Burned",
            subtitleKey: "Goal: 900 kcal",
            image: "flame",
            tintColor: .red,
            amount: "450 kcal",
            goalValue: "900 kcal"
        )
    )
}
