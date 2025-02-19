//
//  HeartRateGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct HeartRateGraph: View {
    var data: [(time: Date, bpm: Double)]

    var body: some View {
        Chart {
            ForEach(data, id: \.time) { entry in
                LineMark(
                    x: .value("Time", entry.time),
                    y: .value("BPM", entry.bpm)
                )
                .foregroundStyle(.red)
                .interpolationMethod(.catmullRom)
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

// 🛠 Mock Data สำหรับ Preview
extension HeartRateGraph {
    static let sampleData: [(time: Date, bpm: Double)] = [
        (time: Date().addingTimeInterval(-3600 * 5), bpm: 75),
        (time: Date().addingTimeInterval(-3600 * 4), bpm: 80),
        (time: Date().addingTimeInterval(-3600 * 3), bpm: 78),
        (time: Date().addingTimeInterval(-3600 * 2), bpm: 90),
        (time: Date().addingTimeInterval(-3600 * 1), bpm: 85),
        (time: Date(), bpm: 88)
    ]
}

#Preview {
    HeartRateGraph(data: HeartRateGraph.sampleData)
}
