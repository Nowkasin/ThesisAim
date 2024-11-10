//
//  ChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 27/10/2567 BE.
//

import SwiftUI

struct ChartView: View {
    @Environment(\.presentationMode) var presentationMode // ตัวแปรสำหรับควบคุมการนำทาง

    var body: some View {
        VStack {
            Text("Hello, World!")
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

