//
//  TodayActivitiesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI

struct TabCardControlView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var scoreManager: ScoreManager
    var textColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Header: Today Activities and Score (ไม่มี background สีใดๆ)
            HStack {
                Text(t("Today Activities", in: "home_screen"))
                    .font(.headline)
                    .foregroundColor(textColor)
                    .padding(.leading, 20)
                Spacer()
                ScoreView() // เรียกใช้ ScoreView ที่แยกออกมาแล้ว
                        .frame(maxWidth: .infinity, alignment: .trailing)
            }
            // Horizontal ScrollView สำหรับ Activity Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(healthManager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                        NavigationLink(destination: destinationView(for: item.value)) {
                            ActivityCard(activity: item.value)
                                .frame(width: 200, height: 180)
                        }
//                        .onAppear {
//                            print("📌 Loading ActivityCard for: \(item.value.titleKey)")
//                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
        }
    }
    
    private func destinationView(for activity: Activity) -> some View {
        let titleKey = activity.titleKey.lowercased()
        let todayHeartRateKey = t("Today Heart Rate", in: "Chart_screen").lowercased()
        let todayStepsKey = t("Today Steps", in: "Chart_screen").lowercased()
        let todayCalKey = t("Today Calories", in: "Chart_screen").lowercased()
        let todayDistanceKey = t("Today's Distance", in: "Chart_screen").lowercased()
        
        if titleKey == todayHeartRateKey {
            return AnyView(HeartChartView(activity: activity))
        } else if titleKey == todayStepsKey {
            return AnyView(StepChartView(activity: activity))
        } else if titleKey == todayCalKey {
            return AnyView(CalChartView(activity: activity))
        } else if titleKey == todayDistanceKey {
            return AnyView(DistanceChartView(activity: activity))
        } else {
            return AnyView(Text("🚨 Error: Unknown Activity (\(activity.titleKey))"))
        }
    }
}
struct TabCardControlView_Previews: PreviewProvider {
    static var previews: some View {
        TabCardControlView(textColor: .primary)
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
    }
}

