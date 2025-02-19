//
//  DistanctChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import SwiftUI
import Charts

struct DistanceChartView: View {
    let activity: Activity  // ✅ รับค่า Activity
    @StateObject private var viewModel = DistanceViewModel() // ✅ ใช้ ViewModel ดึงข้อมูลระยะทาง

    var body: some View {
        List {
            VStack {
                Text(activity.titleKey)
                    .font(.title)
                    .bold()

                // ✅ ใช้ Placeholder Data ถ้ายังไม่มีข้อมูลจริง
                DistanceGraph(data: viewModel.distanceData.isEmpty ? DistanceChartView.placeholderData : viewModel.distanceData)
                    .frame(height: 200)
                    .padding()
                    .transition(.slide)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle(activity.titleKey)
        .onAppear {
            viewModel.fetchTodayDistance()
        }
    }

    // ✅ Placeholder Data (ถ้ายังไม่มีข้อมูลจริง)
    static let placeholderData: [(time: Date, distance: Double)] = [
        (time: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, distance: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, distance: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, distance: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, distance: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, distance: 0),
        (time: Date(), distance: 0)
    ]
}

// 🔍 Preview ใช้ Activity จำลอง
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
