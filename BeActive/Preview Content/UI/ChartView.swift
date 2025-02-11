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
    @StateObject var themeManager = ThemeManager()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var language = Language.shared
    
    let activity: Activity
    @State private var stepsData: [Double] = []
    private let healthStore = HKHealthStore()
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor // พื้นหลังเต็มหน้าจอ
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(t(activity.titleKey, in: "Chart_screen"))
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(themeManager.textColor) // ใช้สีข้อความจาก ThemeManager
                    Text("\(t(activity.subtitleKey, in: "Chart_screen")) ")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textColor)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(t("Amount", in: "Chart_screen")): \(activity.amount)")
                            .foregroundColor(themeManager.textColor)
                    }
                    .padding()
                    
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
                    fetchHealthData()
                }
            }
        }
    }

    private func fetchHealthData() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
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
                                                intervalComponents: DateComponents(day: 1))
        
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
                self.stepsData = stepsPerDay
            }
        }
        
        healthStore.execute(query)
    }
}

#Preview {
    ChartView(activity: Activity(id: 0, titleKey: "Daily Steps", subtitleKey: "", image: "figure.walk", tintColor: .green, amount: "6,234", goalValue: ""))
}
