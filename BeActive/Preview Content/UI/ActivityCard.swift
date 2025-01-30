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

struct ActivityCard: View {
    @StateObject var themeManager = ThemeManager()  // ใช้ @StateObject เพื่อให้ ThemeManager ถูกสร้างครั้งเดียว
    let activity: Activity
    @ObservedObject var language = Language.shared

    var body: some View {
        NavigationLink(destination: ChartView(activity: activity)) {
            ZStack {
                Color(uiColor: .systemGray6)
                    .cornerRadius(15)

                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(t(activity.titleKey, in: "Chart_screen")) // ✅ แปล Title
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            // ✅ ใช้ค่า Goal ที่กำหนดจาก Activity
                            Text("\(t(activity.subtitleKey, in: "Chart_screen")) \(activity.goalValue)")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }

                        Spacer()
                        Image(systemName: activity.image)
                            .foregroundColor(activity.tintColor)
                    }
                    .padding([.top, .leading, .trailing])

                    Text(activity.amount)
                        .font(.system(size: 24))
                        .minimumScaleFactor(0.6)
                        .bold()
                        .padding()
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(id: 0, titleKey: "Daily_Steps", subtitleKey: "",image: "figure.walk", tintColor: .green, amount: "6,234", goalValue: ""))
    }
}
