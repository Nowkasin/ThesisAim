//
//  DistanctChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import SwiftUI
import Charts

struct DistanceChartView: View {
    let activity: Activity
    @StateObject private var viewModel = DistanceViewModel()
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
                Text("\(viewModel.averageDistance, specifier: "%.2f") \(t("KM", in: "Chart.Summary"))")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 34))
                    .foregroundColor(.primary)

                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // ✅ กราฟแสดงผล
            DistanceGraph(data: viewModel.filteredData(for: selectedRange))
                .frame(height: 250)
                .padding()

            Spacer()
        }
        .navigationTitle(activity.titleKey)
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.fetchDistance(for: selectedRange)
        }
        .onChange(of: selectedRange) { newRange in
            viewModel.fetchDistance(for: newRange)
        }
    }
}

#Preview {
    DistanceChartView(activity: Activity(
        id: 4,
        titleKey: "Walking & Running Distance",
        subtitleKey: "Goal: 5 km",
        image: "figure.walk.circle",
        tintColor: .blue,
        amount: "2.5 km",
        goalValue: "5 km"
    ))
}
