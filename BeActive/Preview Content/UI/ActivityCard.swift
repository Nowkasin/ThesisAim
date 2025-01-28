//
//  ActivityCard.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    var subtitleKey: String
    let image: String
    let tintColor: Color
    let amount: String
}

struct ActivityCard: View {
    let activity: Activity
    
    // ตัวอย่างฟังก์ชัน `t` สำหรับการแปล
    func t(_ key: String, in table: String = "Localizable") -> String {
        NSLocalizedString(key, tableName: table, comment: "")
    }
    
    var body: some View {
        NavigationLink(destination: ChartView(activity: activity)) {
            ZStack {
                Color(uiColor: .systemGray6)
                    .cornerRadius(15)
                
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            // ใช้ฟังก์ชัน `t` ในส่วน title และ subtitle
                            Text(t(activity.title, in: "Chart_screen"))
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Text(t(activity.subtitleKey, in: "Chart_screen"))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
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
        .buttonStyle(PlainButtonStyle()) // Removes the default link styling
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(id: 0, title: "Daily_Steps", subtitleKey: "Goal_10K", image: "figure.walk", tintColor: .green, amount: "6,234"))
    }
}
