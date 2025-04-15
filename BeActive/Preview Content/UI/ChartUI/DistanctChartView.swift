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

    var body: some View {
        VStack {
            // ✅ Picker สำหรับเลือกช่วงเวลา
            Picker("ช่วงเวลา", selection: $selectedRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.localized).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // ✅ ข้อมูลสรุปด้านบน
            VStack(alignment: .leading, spacing: 5) {
                Text("\(viewModel.averageDistance, specifier: "%.2f") \(t("km", in: "Chart.Summary"))")
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
