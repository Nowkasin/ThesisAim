//
//  CalChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//


import SwiftUI
import Charts

struct CalChartView: View {
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
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)

            // ✅ ข้อมูลสรุปด้านบน
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.averageCalories, specifier: "%.0f") kcal")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
        .background(Color(.systemBackground))
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

// 🔍 Preview
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
