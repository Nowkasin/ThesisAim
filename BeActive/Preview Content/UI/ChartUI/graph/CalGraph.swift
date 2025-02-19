//
//  CalGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 18/2/2568 BE.
//

import SwiftUI
import Charts

struct CalGraph: View {
    var data: [(time: Date, calories: Double)] // ✅ รับข้อมูลแคลอรี่ที่เผาผลาญ

    var body: some View {
        VStack {
            Chart {
                if data.isEmpty {
                    // ✅ ถ้ายังไม่มีข้อมูลจริง ให้แสดงแกนเปล่าๆ
                    RuleMark(y: .value("Calories", 100))
                        .foregroundStyle(.gray.opacity(0.3))
                    RuleMark(y: .value("Calories", 500))
                        .foregroundStyle(.gray.opacity(0.3))
                } else {
                    ForEach(data, id: \.time) { entry in
                        BarMark(
                            x: .value("Time", entry.time),
                            y: .value("Calories", entry.calories)
                        )
                        .foregroundStyle(.orange)
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
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .frame(height: 250)
            .padding()
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
    CalGraph(data: CalGraph.sampleData)
}

