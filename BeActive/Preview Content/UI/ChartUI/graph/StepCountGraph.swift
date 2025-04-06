//
//  StepGeaph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct StepCountGraph: View {
    var data: [StepData]
    @State private var selectedData: StepData?
    @State private var tooltipXPosition: CGFloat = .zero
    @State private var showTooltip: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Chart {
                    ForEach(data) { entry in
                        BarMark(
                            x: .value("Day", entry.date, unit: .day),
                            y: .value("Steps", entry.steps)
                        )
                        .foregroundStyle(entry.date.isSameDay(as: Date()) ? Color.red : Color.orange)
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
                                        if let matchedData = data.first(where: {
                                            Calendar.current.isDate($0.date, inSameDayAs: xDate)
                                        }) {
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
                    AxisMarks(preset: .automatic, position: .leading)
                }
                .chartXAxis {
                    AxisMarks(format: .dateTime.day().month())
                }
                .frame(height: 250)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 1)
                )
                .animation(.easeInOut(duration: 0.3), value: data)

                if showTooltip, let selected = selectedData {
                    VStack {
                        Text("\(Int(selected.steps)) ก้าว")
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
}

// ✅ ฟังก์ชันตรวจสอบว่าวันเดียวกันหรือไม่
extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
}

// ✅ ตัวอย่าง Preview
#Preview {
    StepCountGraph(data: [
        StepData(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, steps: 5000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, steps: 7500),
        StepData(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, steps: 6000),
        StepData(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, steps: 8200),
        StepData(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, steps: 9100),
        StepData(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, steps: 10000),
        StepData(date: Date(), steps: 4500)
    ])
}

