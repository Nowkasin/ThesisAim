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
            .background(Color(.systemBackground))
            .cornerRadius(8)

            // ✅ ข้อมูลสรุปด้านบน
            VStack(alignment: .leading, spacing: 5) {
                Text("\(Int(viewModel.heartRateRange.min)) - \(Int(viewModel.heartRateRange.max)) BPM")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)

                Text("Avg: \(Int(viewModel.averageBPM)) BPM")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(viewModel.dateRangeText(for: selectedRange))
                    .font(.subheadline)
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
        .navigationTitle(activity.titleKey)
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
