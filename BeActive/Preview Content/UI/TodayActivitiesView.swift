//
//  TodayActivitiesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI

struct TodayActivitiesView: View {
    @EnvironmentObject var manager: HealthManager
    var textColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                        NavigationLink(destination: destinationView(for: item.value)) {
                            ActivityCard(activity: item.value)
                                .frame(width: 200, height: 180)
                        }
                        .onAppear {
                            print("📌 Loading ActivityCard for: \(item.value.titleKey)") // ✅ Debugging Print ถูกต้อง
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func destinationView(for activity: Activity) -> some View {
        let titleKey = activity.titleKey.lowercased() // ✅ แปลงเป็นตัวพิมพ์เล็กเพื่อให้ตรวจสอบง่าย
        let todayHeartRateKey = t("Today Heart Rate", in: "Chart_screen").lowercased() // ✅ ใช้ `.lowercased()` ด้วย
        let todayStepsKey = t("Today Steps", in: "Chart_screen").lowercased() // ✅ ใช้ `.lowercased()` ด้วย
        let todaycal = t("Today Calories", in: "Chart_screen").lowercased()
        let todaydistance = t("Today's Distance", in: "Chart_screen").lowercased()

        print("📌 Navigating to: \(activity.titleKey)") // ✅ Debugging Print
        print("🔍 Expected Heart Rate Key: \(todayHeartRateKey)")
        print("🔍 Expected Steps Key: \(todayStepsKey)")

        if titleKey == todayHeartRateKey {
            return AnyView(HeartChartView(activity: activity)) // ✅ รองรับการแปลภาษา
        } else if titleKey == todayStepsKey {
            return AnyView(StepChartView(activity: activity)) // ✅ รองรับการแปลภาษา
        } else if titleKey == todaycal {
            return AnyView(CalChartView(activity: activity)) // ✅ รองรับการแปลภาษา
        } else if titleKey == todaydistance {
            return AnyView(DistanceChartView(activity: activity)) // ✅ รองรับการแปลภาษา
        } else {
            return AnyView(Text("🚨 Error: Unknown Activity (\(activity.titleKey))")) // ✅ แสดง Error ถ้าชื่อไม่ถูกต้อง
        }
    }
}

