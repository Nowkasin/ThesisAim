//
//  ChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 27/10/2567 BE.
//

import SwiftUI

struct ChartView: View {
    @Environment(\.dismiss) var dismiss  // สำหรับให้ปุ่มสามารถกลับไปยังหน้า Home

    var body: some View {
        VStack {
            Text("Hello, Chart!")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {  // ปุ่มวางที่มุมบนซ้าย
                Button(action: {
                    dismiss()  // กลับไปยังหน้า Home
                }) {
                    Image(systemName: "chevron.left") // ไอคอนลูกศรซ้าย
                    Text("Back") // ข้อความ "Back"
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChartView()
    }
}
