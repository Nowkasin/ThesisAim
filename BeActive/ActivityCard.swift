//
//  ActivityCard.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI

struct Activity: Identifiable {
    var id: Int
    var titleKey: String
    var image: String
    var tintColor: Color
    var amount: String
}


struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        NavigationLink(destination: ChartView(activity: activity)) {
            ZStack {
                Color(uiColor: .systemGray6)
                    .cornerRadius(15)
                
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            // ใช้ t() เพื่อแปล titleKey และ subtitleKey
                            Text(t(activity.titleKey, in: "Chart_screen"))  // แปล title
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
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
        .buttonStyle(PlainButtonStyle()) // ลบสไตล์ลิงก์เริ่มต้น
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(id: 0, titleKey: "daily_steps", image: "figure.walk", tintColor: .green, amount: "6,234"))
    }
}

