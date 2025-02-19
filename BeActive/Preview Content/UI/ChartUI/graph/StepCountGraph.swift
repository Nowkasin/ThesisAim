//
//  StepGeaph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct StepCountGraph: View {
    var data: [(date: Date, steps: Double)]

    var body: some View {
        Chart {
            ForEach(data, id: \.date) { entry in
                BarMark(
                    x: .value("Day", entry.date, unit: .day),
                    y: .value("Steps", entry.steps)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks()
        }
        .frame(height: 200)
    }
}

// ✅ แก้ไข `#Preview` ให้ถูกต้อง
#Preview {
    StepCountGraph(data: [
        (date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, steps: 5000),
        (date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, steps: 7500),
        (date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, steps: 6000),
        (date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, steps: 8200),
        (date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, steps: 9100),
        (date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, steps: 10000),
        (date: Date(), steps: 4500)
    ])
}
