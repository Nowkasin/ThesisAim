//
//  CalChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//


import SwiftUI
import Charts

struct CalChartView: View {
    @ObservedObject var language = Language.shared
    let activity: Activity
    @StateObject private var viewModel = CalorieViewModel()
    @State private var selectedRange: TimeRange = .today

    var body: some View {
        VStack {
            // ✅ Custom Segmented Picker สำหรับเลือกช่วงเวลา
            HStack(spacing: 8) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedRange = range
                    }) {
                        Text(range.localized)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 14))
                            .foregroundColor(selectedRange == range ? .white : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selectedRange == range ? Color.accentColor : Color(.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)

            // ✅ ข้อมูลสรุปด้านบน
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.averageCalories, specifier: "%.0f") \(t("Kcal", in: "Chart.Summary"))")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 34))
                    .foregroundColor(.primary)
                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
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
