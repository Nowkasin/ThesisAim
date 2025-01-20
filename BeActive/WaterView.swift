//
//  WaterView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 4/11/2567 BE.
//

import SwiftUI

struct WaterView: View {
    @Environment(\.presentationMode) var presentationMode // ตัวแปรสำหรับควบคุมการนำทาง
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Water Reminder")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

#Preview {
    WaterView()
}
