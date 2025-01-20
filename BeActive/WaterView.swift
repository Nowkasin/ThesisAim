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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { // ปุ่ม Back ที่มุมซ้ายบน
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // กลับไปยังหน้า Home
                    }) {
                        Image(systemName: "chevron.left") // ไอคอนลูกศรย้อนกลับ
                        Text("Home")
                    }
                }
            }
        }
    }
}

#Preview {
    WaterView()
}
