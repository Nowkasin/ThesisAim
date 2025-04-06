//
//  CalGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 18/2/2568 BE.
//

import SwiftUI
import Charts

struct CalGraph: View {
    var data: [CalorieData]
    var timeRange: TimeRange

    @State private var selectedData: CalorieData?
    @State private var tooltipXPosition: CGFloat = .zero
    @State private var showTooltip: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Chart {
                    if data.isEmpty {
                        RuleMark(y: .value("Calories", 100))
                            .foregroundStyle(.gray.opacity(0.3))
                        RuleMark(y: .value("Calories", 500))
                            .foregroundStyle(.gray.opacity(0.3))
                    } else {
                        ForEach(data) { entry in
                            BarMark(
                                x: .value("Time", entry.time, unit: xAxisUnit()),
                                y: .value("Calories", entry.calories)
                            )
                            .foregroundStyle(Color.orange)
                        }
                    }
                }
                .chartOverlay { proxy in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let position = value.location
                                    if let xDate: Date = proxy.value(atX: position.x) {
                                        if let matchedData = data.first(where: { Calendar.current.isDate($0.time, inSameDayAs: xDate) }) {
                                            selectedData = matchedData
                                            if let barPositionX = proxy.position(forX: xDate) {
                                                tooltipXPosition = barPositionX
                                            }
                                            showTooltip = true
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        showTooltip = false
                                    }
                                }
                        )
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: xAxisLabelFormat())
                    }
                }
                .frame(height: 250)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                )
                .animation(.easeInOut(duration: 0.3), value: data)

                if showTooltip, let selected = selectedData {
                    VStack {
                        Text("\(Int(selected.calories)) แคลอรี่")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 5)
                            )
                            .offset(x: tooltipXPosition - geo.size.width / 2, y: -120)
                    }
                }
            }
        }
    }

    private func xAxisUnit() -> Calendar.Component {
        switch timeRange {
        case .today, .week:
            return .hour
        case .month, .sixMonths, .year:
            return .month
        }
    }

    private func xAxisLabelFormat() -> Date.FormatStyle {
        switch timeRange {
        case .today, .week:
            return .dateTime.hour().minute()
        case .month, .sixMonths, .year:
            return .dateTime.month()
        }
    }
}

// ✅ ตัวอย่างข้อมูลสำหรับ Preview
extension CalGraph {
    static let sampleData: [CalorieData] = [
        CalorieData(time: Date().addingTimeInterval(-3600 * 5), calories: 200),
        CalorieData(time: Date().addingTimeInterval(-3600 * 4), calories: 250),
        CalorieData(time: Date().addingTimeInterval(-3600 * 3), calories: 230),
        CalorieData(time: Date().addingTimeInterval(-3600 * 2), calories: 280),
        CalorieData(time: Date().addingTimeInterval(-3600 * 1), calories: 260),
        CalorieData(time: Date(), calories: 300)
    ]
}

#Preview {
    CalGraph(data: CalGraph.sampleData, timeRange: .today)
}
