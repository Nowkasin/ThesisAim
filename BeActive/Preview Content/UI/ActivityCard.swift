//
//  ActivityCard.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI

struct Activity {
    let id: Int
    let titleKey: String
    var subtitleKey: String
    let image: String
    let tintColor: Color
    let amount: String
    var goalValue: String
}

// 🃏 ActivityCard (แสดงการ์ดแต่ละกิจกรรม)
struct ActivityCard: View {
    @ObservedObject var language = Language.shared
    let activity: Activity

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .cornerRadius(15)

            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.titleKey)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 14))
                            .foregroundColor(.primary)

                        Text(t(activity.subtitleKey, in: "Chart_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: activity.image)
                        .foregroundColor(activity.tintColor)
                }
                .padding([.top, .leading, .trailing])

                Text(activity.amount)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 24))
                    .minimumScaleFactor(0.6)
                    .foregroundColor(.primary)
                    .padding()
            }
        }
        .padding()
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 3)
        .onAppear {
            print("📌 ActivityCard Loaded: \(activity.titleKey)")
        }
    }
}

// 🔍 Preview สำหรับดูตัวอย่าง UI
struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                ActivityCard(activity: Activity(id: 1, titleKey: "Today Heart Rate", subtitleKey: "74-98 BPM", image: "heart.fill", tintColor: .red, amount: "85 BPM", goalValue: "60-100 BPM"))

                ActivityCard(activity: Activity(id: 2, titleKey: "Daily Steps", subtitleKey: "Goal: 10,000 Steps", image: "figure.walk", tintColor: .green, amount: "6,234", goalValue: "10,000 Steps"))

                ActivityCard(activity: Activity(id: 3, titleKey: "Today Calories", subtitleKey: "goal: 1,500 calories", image: "flame", tintColor: .red, amount: "1,200", goalValue: "900 calories"))

                ActivityCard(activity: Activity(id: 4, titleKey: "Today Distance", subtitleKey: "goal: 5 KM.", image: "figure.running", tintColor: .blue, amount: "5 km", goalValue: "5 km"))
            }
            .padding()
            .preferredColorScheme(.light)

            VStack {
                ActivityCard(activity: Activity(id: 1, titleKey: "Today Heart Rate", subtitleKey: "74-98 BPM", image: "heart.fill", tintColor: .red, amount: "85 BPM", goalValue: "60-100 BPM"))

                ActivityCard(activity: Activity(id: 2, titleKey: "Daily Steps", subtitleKey: "Goal: 10,000 Steps", image: "figure.walk", tintColor: .green, amount: "6,234", goalValue: "10,000 Steps"))

                ActivityCard(activity: Activity(id: 3, titleKey: "Today Calories", subtitleKey: "goal: 1,500 calories", image: "flame", tintColor: .red, amount: "1,200", goalValue: "900 calories"))

                ActivityCard(activity: Activity(id: 4, titleKey: "Today Distance", subtitleKey: "goal: 5 KM.", image: "figure.running", tintColor: .blue, amount: "5 km", goalValue: "5 km"))
            }
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}

