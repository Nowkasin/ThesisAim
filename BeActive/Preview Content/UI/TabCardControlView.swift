//
//  TodayActivitiesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI

import Kingfisher

struct TabCardControlView: View {
    @ObservedObject var language = Language.shared
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var scoreManager: ScoreManager
    @AppStorage("selectedMate") private var selectedMate: String = "Bear"

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let cardWidth = min(screenWidth * 0.45, 200) // Responsive but capped
            let cardHeight = cardWidth * 0.9 // Maintain ratio
            let _ = language.currentLanguage

            VStack(alignment: .leading, spacing: 5) {
                // Header: Today Activities and Score
                HStack {
                    HStack(spacing: 2) {
                        Text(t("Today Activities", in: "home_screen"))
                        KFImage(URL(string: selectedMateImageUrl()))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] }
                    }
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                    Spacer()

                    ScoreView()
                        .offset(x: 20) // Move ScoreView 20 points to the right
                }
                .padding(.horizontal, 20)

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

    private func selectedMateImageUrl() -> String {
        switch selectedMate {
        case "Cat": return "https://i.imgur.com/5ym20Wl.png"
        case "Happy Cat": return "https://i.imgur.com/0JJOJbK.png"
        case "Lovely Cat": return "https://i.imgur.com/TRIDeEw.png"
        case "Bunny": return "https://i.imgur.com/if52U93.png"
        case "Happy Bunny": return "https://i.imgur.com/ZZlNIjX.png"
        case "Lovely Bunny": return "https://i.imgur.com/VLvp9Qm.png"
        case "Chick": return "https://i.imgur.com/ay4YRSm.png"
        case "Happy Chick": return "https://i.imgur.com/YBn2oFH.png"
        case "Lovely Chick": return "https://i.imgur.com/YPFM2Bu.png"
        case "Dog": return "https://i.imgur.com/RObtJjY.png"
        case "Happy Dog": return "https://i.imgur.com/YiEE02e.png"
        case "Lovely Dog": return "https://i.imgur.com/y3ocZ22.png"
        case "Mocha": return "https://i.imgur.com/sY0fdeH.png"
        case "Happy Bear": return "https://i.imgur.com/mTEiOqd.png"
        case "Lovely Bear": return "https://i.imgur.com/OT2vJPe.png"
        default: return "https://i.imgur.com/TR7HwEa.png"
        }
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
