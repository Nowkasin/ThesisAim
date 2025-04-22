//
//  DistanceGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import SwiftUI
import Charts

struct DistanceGraph: View {
    @ObservedObject var language = Language.shared
    var data: [DistanceData]
    @State private var selectedData: DistanceData?
    @State private var tooltipXPosition: CGFloat = .zero
    @State private var showTooltip: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Chart {
                    ForEach(data) { entry in
                        BarMark(
                            x: .value("Time", entry.time),
                            y: .value("Distance", entry.distance)
                        )
                        .foregroundStyle(entry.time.isSameHour(as: Date()) ? Color.red : Color.blue)
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
                                            Calendar.current.isDate($0.time, equalTo: xDate, toGranularity: .hour)
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
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.hour().minute())
                    }
                }
                .frame(height: 250)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                .animation(.easeInOut(duration: 0.3), value: data)

                if showTooltip, let selected = selectedData {
                    VStack {
                        Text("\(String(format: "%.2f", selected.distance)) กม.")
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
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

// ✅ ฟังก์ชันตรวจสอบว่าชั่วโมงเดียวกันหรือไม่
extension Date {
    func isSameHour(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: otherDate, toGranularity: .hour)
    }
}

// ✅ ตัวอย่าง Preview
#Preview {
    DistanceGraph(data: [
        DistanceData(time: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, distance: 1.2),
        DistanceData(time: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, distance: 2.4),
        DistanceData(time: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, distance: 1.8),
        DistanceData(time: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, distance: 3.0),
        DistanceData(time: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, distance: 2.6),
        DistanceData(time: Date(), distance: 3.5)
    ])
}
