//
//  CalGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 18/2/2568 BE.
//

import SwiftUI
import Charts

struct CalGraph: View {
    var data: [(time: Date, calories: Double)]
    var timeRange: TimeRange  // ✅ รับค่าช่วงเวลาจาก ViewModel

    var body: some View {
        VStack {
            Chart {
                if data.isEmpty {
                    // ✅ ถ้ายังไม่มีข้อมูลจริง ให้แสดงเส้นแกนเปล่าๆ
                    RuleMark(y: .value("Calories", 100))
                        .foregroundStyle(.gray.opacity(0.3))
                    RuleMark(y: .value("Calories", 500))
                        .foregroundStyle(.gray.opacity(0.3))
                } else {
                    ForEach(data, id: \.time) { entry in
                        BarMark(
                            x: .value("Time", entry.time, unit: xAxisUnit()),
                            y: .value("Calories", entry.calories)
                        )
                        .foregroundStyle(.orange) // ✅ เปลี่ยนสีให้เหมือน Apple Health
                    }
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
                    AxisValueLabel(format: xAxisLabelFormat()) // ✅ ปรับการแสดงผลตามช่วงเวลา
                }
            }
            .frame(height: 250)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))) // ✅ เพิ่ม Background
        }
    }

    // ✅ ฟังก์ชันกำหนดหน่วยของแกน X ตามช่วงเวลา
    private func xAxisUnit() -> Calendar.Component {
        switch timeRange {
        case .today, .week:
            return .hour  // ✅ แสดงผลเป็นรายชั่วโมง
        case .month, .sixMonths, .year:
            return .month  // ✅ แสดงผลเป็นรายเดือน
        }
    }

    // ✅ ฟังก์ชันกำหนดฟอร์แมตของแกน X
    private func xAxisLabelFormat() -> Date.FormatStyle {
        switch timeRange {
        case .today, .week:
            return .dateTime.hour().minute()  // ✅ แสดงเป็นเวลา (08:00, 12:00, …)
        case .month, .sixMonths, .year:
            return .dateTime.month()  // ✅ แสดงเป็นเดือน (Jan, Feb, …)
        }
    }
}

// ✅ Mock Data สำหรับ Preview
extension CalGraph {
    static let sampleData: [(time: Date, calories: Double)] = [
        (time: Date().addingTimeInterval(-3600 * 5), calories: 200),
        (time: Date().addingTimeInterval(-3600 * 4), calories: 250),
        (time: Date().addingTimeInterval(-3600 * 3), calories: 230),
        (time: Date().addingTimeInterval(-3600 * 2), calories: 280),
        (time: Date().addingTimeInterval(-3600 * 1), calories: 260),
        (time: Date(), calories: 300)
    ]
}

#Preview {
    CalGraph(data: CalGraph.sampleData, timeRange: .today)
}
