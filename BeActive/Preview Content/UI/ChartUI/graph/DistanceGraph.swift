//
//  DistanceGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/2/2568 BE.
//

import SwiftUI
import Charts

struct DistanceGraph: View {
    @StateObject var themeManager = ThemeManager() // ✅ ใช้งาน ThemeManager
    var data: [DistanceData] // ✅ ใช้ DistanceData แทน Tuple เพื่อความสม่ำเสมอ
    @State private var selectedData: DistanceData? // ✅ เก็บค่าที่ถูกเลือก
    @State private var tooltipXPosition: CGFloat = .zero // ✅ เก็บตำแหน่ง X ของ Tooltip
    @State private var showTooltip: Bool = false // ✅ ควบคุมการแสดง Tooltip

    var body: some View {
        GeometryReader { geo in // ✅ ใช้ GeometryReader ครอบทั้งหมด
            ZStack {
                Chart {
                    ForEach(data) { entry in
                        BarMark(
                            x: .value("Time", entry.time),
                            y: .value("Distance", entry.distance)
                        )
                        .foregroundStyle(entry.time.isSameHour(as: Date()) ? Color.red : Color.blue) // ✅ ใช้สีแดงสำหรับแท่งปัจจุบัน
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
                                        if let matchedData = data.first(where: { Calendar.current.isDate($0.time, equalTo: xDate, toGranularity: .hour) }) {
                                            selectedData = matchedData
                                            if let barPositionX = proxy.position(forX: xDate) {
                                                tooltipXPosition = barPositionX // ✅ ให้ Tooltip อยู่ตรงกลาง Bar
                                            }
                                            showTooltip = true
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        showTooltip = false // ✅ ซ่อน Tooltip หลังจาก 1 วินาที
                                    }
                                }
                        )
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
                .background(RoundedRectangle(cornerRadius: 10).fill(themeManager.backgroundColor)) // ✅ เปลี่ยนพื้นหลังกราฟตามธีม
                .animation(.easeInOut(duration: 0.3), value: data)

                // ✅ Tooltip ที่อยู่ตรงกลางของแท่งกราฟ
                if showTooltip, let selected = selectedData {
                    VStack {
                        Text("\(String(format: "%.2f", selected.distance)) กม.")
                            .font(.headline)
                            .bold()
                            .foregroundColor(themeManager.textColor) // ✅ เปลี่ยนสีตัวอักษรของ Tooltip ตามธีม
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                            .offset(x: tooltipXPosition - geo.size.width / 2, y: -120) // ✅ อยู่ตรงกลางแท่งกราฟ
                    }
                }
            }
        }
    }
}

// ✅ ฟังก์ชันตรวจสอบว่าชั่วโมงเดียวกันหรือไม่
extension Date {
    func isSameHour(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: otherDate, toGranularity: .hour)
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
        DistanceData(time: Date(), distance: 3.5) // 🔥 ชั่วโมงปัจจุบันเป็นสีแดง
    ])
}
