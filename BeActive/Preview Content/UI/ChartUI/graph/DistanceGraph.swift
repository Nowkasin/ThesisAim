//
//  DistanceGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import SwiftUI
import Charts

struct DistanceGraph: View {
    var data: [(time: Date, distance: Double)] // ✅ รับข้อมูลระยะทางจริงจาก HealthKit

    var body: some View {
        VStack {
            
            Chart {
                ForEach(data, id: \.time) { entry in
                    BarMark(
                        x: .value("Time", entry.time),
                        y: .value("Distance", entry.distance)
                    )
                    .foregroundStyle(.blue) // ✅ ใช้สีน้ำเงินแทนการเดิน/วิ่ง
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.hour().minute()) // ✅ แสดงเวลาเป็น ชั่วโมง:นาที
                }
            }
            .frame(height: 250)
            .padding()
        }
    }
}


// 🔍 Preview สำหรับทดสอบ UI
#Preview {
    DistanceGraph(data: [
        (time: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, distance: 1.2),
        (time: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, distance: 2.4),
        (time: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, distance: 1.8),
        (time: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, distance: 3.0),
        (time: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, distance: 2.6),
        (time: Date(), distance: 3.5)
    ])
}
