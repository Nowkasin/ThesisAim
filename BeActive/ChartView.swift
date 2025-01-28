//
//  ChartView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 27/10/2567 BE.
//

import SwiftUI
import HealthKit
import Charts

struct ChartView: View {
    @Environment(\.presentationMode) var presentationMode
    let activity: Activity // รับข้อมูล Activity จาก ActivityCard
    
    @State private var stepsData: [Double] = [] // ตัวแปรสำหรับเก็บข้อมูลจำนวนขั้นตอน
    private let healthStore = HKHealthStore()

    var body: some View {
        NavigationView {
            VStack {
                Text(t(activity.titleKey, in: "Chart_screen")) // ใช้ฟังก์ชัน t() แทนการแสดง activity.title
                    .font(.largeTitle)
                    .padding()

                VStack(alignment: .leading, spacing: 5) {
                    Text("\(t("Amount", in: "Chart_screen")): \(activity.amount)") // แปลคำว่า "Amount"
                }
                .padding()

                // แสดงกราฟที่เกี่ยวข้องกับ activity
                // กรณีนี้จะใช้ข้อมูลจำนวนขั้นตอน
                Chart {
                    ForEach(0..<stepsData.count, id: \.self) { index in
                        BarMark(
                            x: .value("Day", index + 1),
                            y: .value("Steps", stepsData[index])
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 300)
                .padding()
            }
           
            .onAppear {
                fetchHealthData() // ดึงข้อมูลเมื่อหน้าแสดงผล
            }
        }
    }
    
    // ฟังก์ชันเพื่อดึงข้อมูลจาก HealthKit
    private func fetchHealthData() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        // กำหนดเวลาเริ่มต้นและสิ้นสุด (ตัวอย่างนี้ใช้ 7 วันย้อนหลัง)
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: now) else {
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictEndDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                 quantitySamplePredicate: predicate,
                                                 options: .cumulativeSum,
                                                 anchorDate: now,
                                                 intervalComponents: DateComponents(day: 1)) // ข้อมูลรายวัน
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                return
            }
            
            var stepsPerDay: [Double] = []
            
            statsCollection.enumerateStatistics(from: startDate, to: now) { statistics, stop in
                let steps = statistics.sumQuantity()?.doubleValue(for: .count())
                stepsPerDay.append(steps ?? 0.0)
            }
            
            DispatchQueue.main.async {
                self.stepsData = stepsPerDay // กำหนดข้อมูลลงในตัวแปร
            }
        }
        
        healthStore.execute(query)
    }
}

#Preview {
    ChartView(activity: Activity(id: 0, titleKey: "Daily Steps", image: "figure.walk", tintColor: .green, amount: "6,234"))
}
