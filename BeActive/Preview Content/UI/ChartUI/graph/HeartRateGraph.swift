//
//  HeartRateGraph.swift
//  BeActive
//
//  Created by Kasin Thappawan on 13/2/2568 BE.
//

import SwiftUI
import Charts

struct HeartRateGraph: View {
    @ObservedObject var viewModel: HeartRateViewModel
    var timeRange: TimeRange

    @ObservedObject var language = Language.shared

    @State private var selectedData: HeartRateData?
    @State private var tooltipXPosition: CGFloat = .zero
    @State private var showTooltip: Bool = false

    var body: some View {
        let data = viewModel.filteredData(for: timeRange)

        GeometryReader { geo in
            ZStack {
                Chart {
                    if data.isEmpty {
                        RuleMark(y: .value("BPM", 50))
                            .foregroundStyle(.gray.opacity(0.3))
                        RuleMark(y: .value("BPM", 100))
                            .foregroundStyle(.gray.opacity(0.3))
                    } else {
                        ForEach(data) { entry in
                            LineMark(
                                x: .value("Time", entry.time, unit: xAxisUnit()),
                                y: .value("BPM", entry.bpm)
                            )
                            .foregroundStyle(.red)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                }
                .chartOverlay { proxy in
                    Rectangle()
                        .fill(Color.clear)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let position = value.location
                                    if let xDate: Date = proxy.value(atX: position.x) {
                                        if let matchedData = data.min(by: { abs($0.time.timeIntervalSince(xDate)) < abs($1.time.timeIntervalSince(xDate)) }) {
                                            selectedData = matchedData
                                            if let linePositionX = proxy.position(forX: xDate) {
                                                tooltipXPosition = linePositionX
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
                        .shadow(radius: 2)
                )
                .animation(.easeInOut(duration: 0.3), value: data)

                if showTooltip, let selected = selectedData {
                    VStack {
                        Text("\(Int(selected.bpm)) BPM")
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

// ✅ Preview
#Preview {
    HeartRateGraph(viewModel: HeartRateViewModel(), timeRange: .today)
}
