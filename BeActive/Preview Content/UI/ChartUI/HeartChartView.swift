//
//  HeartChart.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct HeartChartView: View {
    let activity: Activity
    @StateObject private var viewModel = HeartRateViewModel()
    @State private var selectedRange: TimeRange = .today
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
                Text("\(Int(viewModel.heartRateRange.min)) - \(Int(viewModel.heartRateRange.max)) \(t("BPM", in: "Chart.Summary"))")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 34))
                    .foregroundColor(.primary)

                Text("\(t("Average", in: "Chart.Summary")): \(Int(viewModel.averageBPM)) \(t("BPM", in: "Chart.Summary"))")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .foregroundColor(.primary)

                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // ✅ กราฟแสดงผล
            HeartRateGraph(viewModel: viewModel, timeRange: selectedRange)
                .frame(height: 250)
                .padding()

            Spacer()
        }
        .navigationTitle(t(activity.titleKey, in: "Chart.UI"))
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.fetchHeartRate(for: selectedRange)
        }
        .onChange(of: selectedRange) { newRange in
            viewModel.fetchHeartRate(for: newRange)
        }
    }
}


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
