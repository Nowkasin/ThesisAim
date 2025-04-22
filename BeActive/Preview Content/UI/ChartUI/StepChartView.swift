//
//  StepChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct StepChartView: View {
    let activity: Activity
    @StateObject private var viewModel = StepCountViewModel()
    @State private var selectedRange: TimeRange = .month
    @ObservedObject var language = Language.shared

    var body: some View {
        VStack {
            // ✅ Picker สำหรับเลือกช่วงเวลา
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
                Text("\(viewModel.averageSteps, specifier: "%.0f") \(t("Steps", in: "Chart.Summary"))")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 34))
                    .foregroundColor(.primary)

                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // ✅ กราฟแสดงผล
            StepCountGraph(data: viewModel.filteredData(for: selectedRange))
                .frame(height: 250)
                .padding()

            Spacer()
        }
        .navigationTitle(t(activity.titleKey, in: "Chart.UI"))
        .background(Color(.systemBackground))
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
