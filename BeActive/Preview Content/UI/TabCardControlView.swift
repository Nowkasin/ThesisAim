//
//  TodayActivitiesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI

struct TabCardControlView: View {
    @ObservedObject var language = Language.shared
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var scoreManager: ScoreManager

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let cardWidth = min(screenWidth * 0.45, 200) // Responsive but capped
            let cardHeight = cardWidth * 0.9 // Maintain ratio
            let _ = language.currentLanguage

            VStack(alignment: .leading, spacing: 5) {
                // Header: Today Activities and Score
                HStack {
                    Text(t("Today Activities", in: "home_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
//                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.leading, 20)

                    Spacer()

                    ScoreView()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // Horizontal ScrollView สำหรับ Activity Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(healthManager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                            NavigationLink(destination: destinationView(for: item.value).id(language.currentLanguage)) {
                                ActivityCard(activity: item.value)
                                    .frame(width: cardWidth, height: cardHeight)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
        }
        .frame(height: 220) // Prevent GeometryReader from expanding indefinitely
    }

    private func destinationView(for activity: Activity) -> some View {
        // Ensure the view reevaluates on language change
        _ = language.currentLanguage
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
        TabCardControlView()
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
