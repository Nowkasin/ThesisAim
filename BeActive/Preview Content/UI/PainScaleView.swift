//
//  PainScaleView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI

struct PainRecord: Identifiable {
    let id = UUID()
    let timestamp: Date
    let values: [String: Int]
}

struct PainScaleView: View {
    @State private var headPain: Double = 0
    @State private var armPain: Double = 0
    @State private var shoulderPain: Double = 0
    @State private var backPain: Double = 0
    @State private var legPain: Double = 0
    @State private var footPain: Double = 0

    @State private var history: [PainRecord] = []
    @State private var showHistory = false

    @State private var showSaveConfirmation = false
    @State private var showDeleteConfirmation = false

    @State private var showSaveAlert = false
    @State private var recordToDelete: PainRecord?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Pain Scale")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                // ✅ Local image from assets
                Image("PainScale")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)

                // 🧍 Sliders
                painSlider(label: "Head", value: $headPain)
                painSlider(label: "Arm", value: $armPain)
                painSlider(label: "Shoulder", value: $shoulderPain)
                painSlider(label: "Back", value: $backPain)
                painSlider(label: "Leg", value: $legPain)
                painSlider(label: "Foot", value: $footPain)

                // 💾 Save Button
                Button(action: {
                    showSaveAlert = true
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                if !history.isEmpty {
                    Button(action: {
                        withAnimation {
                            showHistory.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(showHistory ? "Hide History" : "Show History")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    }
                }

                if showHistory && !history.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(history.reversed()) { record in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Button(role: .destructive) {
                                        recordToDelete = record
                                        showDeleteAlert = true
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }

                                ForEach(record.values.sorted(by: { $0.key < $1.key }), id: \.key) { part, value in
                                    HStack {
                                        Text(part)
                                        Spacer()
                                        Text("\(value)").bold()
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(.systemBackground))
        .alert("Save Pain Scale?", isPresented: $showSaveAlert) {
            Button("Save", role: .none, action: savePainData)
            Button("Cancel", role: .cancel) { }
        }

        .alert("Delete this record?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let record = recordToDelete {
                    deleteRecord(record)
                }
            }
            Button("Cancel", role: .cancel) { recordToDelete = nil }
        }

        .overlay(
            VStack(spacing: 10) {
                if showSaveConfirmation {
                    Text("Pain Scale Saved!")
                        .font(.subheadline)
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if showDeleteConfirmation {
                    Text("Record Deleted")
                        .font(.subheadline)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 50)
        )
        .animation(.easeInOut, value: showSaveConfirmation || showDeleteConfirmation)
    }

    func painSlider(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(sliderColor(for: value.wrappedValue))
                        .frame(width: CGFloat(value.wrappedValue / 10) * geometry.size.width, height: 8)

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            LongPressGesture(minimumDuration: 0.3)
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onChanged { gestureValue in
                                    if case .second(true, let drag?) = gestureValue {
                                        let location = drag.location.x
                                        let percent = max(0, min(1, location / geometry.size.width))
                                        value.wrappedValue = round(percent * 10)
                                    }
                                }
                        )
                }
            }
            .frame(height: 30)

            HStack {
                ForEach(0...10, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }

    func sliderColor(for value: Double) -> Color {
        switch value {
        case 0:
            return .green
        case 1...3:
            return Color.green.opacity(0.8)
        case 4...6:
            return .yellow
        case 7...8:
            return .orange
        default:
            return .red
        }
    }

    func savePainData() {
        let newRecord = PainRecord(
            timestamp: Date(),
            values: [
                "Head": Int(headPain),
                "Arm": Int(armPain),
                "Shoulder": Int(shoulderPain),
                "Back": Int(backPain),
                "Leg": Int(legPain),
                "Foot": Int(footPain)
            ]
        )
        history.append(newRecord)

        withAnimation {
            showSaveConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveConfirmation = false
            }
        }
    }

    func deleteRecord(_ record: PainRecord) {
        history.removeAll { $0.id == record.id }

        withAnimation {
            showDeleteConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showDeleteConfirmation = false
            }
        }
    }
}

struct PainScaleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PainScaleView().preferredColorScheme(.light)
            PainScaleView().preferredColorScheme(.dark)
        }
    }
}



