//
//  CalChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//


import SwiftUI
import Charts

struct CalChartView: View {
    let activity: Activity  // ✅ รับค่า Activity
    @StateObject private var viewModel = CalorieViewModel() // ✅ ใช้ ViewModel ดึงข้อมูลแคลอรี่

    var body: some View {
        List {
            VStack {
                Text(activity.titleKey)
                    .font(.title)
                    .bold()

                // ✅ ใช้ข้อมูล Placeholder ถ้ายังไม่มีข้อมูลจริง
                CalGraph(data: viewModel.caloriesData.isEmpty ? CalChartView.placeholderData : viewModel.caloriesData)
                    .frame(height: 200)
                    .padding()
                    .transition(.slide)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle(activity.titleKey)
        .onAppear {
            viewModel.fetchTodayCalories()
        }
    }
    
    // ✅ Placeholder Data (ถ้ายังไม่มีข้อมูลจริง)
    static let placeholderData: [(time: Date, calories: Double)] = [
        (time: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, calories: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, calories: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, calories: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, calories: 0),
        (time: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, calories: 0),
        (time: Date(), calories: 0)
    ]
}

// 🔍 Preview ใช้ Activity จำลอง
#Preview {
    CalChartView(activity: Activity(
        id: 3,
        titleKey: "Calories Burned",
        subtitleKey: "Goal: 900 kcal",
        image: "flame",
        tintColor: .red,
        amount: "450 kcal",
        goalValue: "900 kcal"
    ))
}
