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

    let faceScaleImageURL = URL(string: "https://i.imgur.com/TR7HwEa.png")!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // 🔠 Title
                Text("Pain Scale")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.salmonPink)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                // 🖼️ Face image
                AsyncImage(url: faceScaleImageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                            .padding(.horizontal)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    @unknown default:
                        EmptyView()
                    }
                }

                // 🧍 Sliders
                painSlider(label: "Head", value: $headPain)
                painSlider(label: "Arm", value: $armPain)
                painSlider(label: "Shoulder", value: $shoulderPain)
                painSlider(label: "Back", value: $backPain)
                painSlider(label: "Leg", value: $legPain)
                painSlider(label: "Foot", value: $footPain)

                // 💾 Save Button
                Button(action: savePainData) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)

                // 🕓 History
                if !history.isEmpty {
                    Text("Saved History")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)

                    ForEach(history.reversed()) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(record.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            ForEach(record.values.sorted(by: { $0.key < $1.key }), id: \.key) { part, value in
                                HStack {
                                    Text(part)
                                    Spacer()
                                    Text("\(value)")
                                        .bold()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
    }

    func painSlider(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 40/255, green: 54/255, blue: 85/255))

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(sliderColor(for: value.wrappedValue))
                        .frame(width: CGFloat(value.wrappedValue / 10) * geometry.size.width, height: 8)
                    
                    // Full-width transparent layer for sliding
                    Color.clear
                        .contentShape(Rectangle()) // Make sure full width is tappable
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let location = gesture.location.x
                                    let percent = max(0, min(1, location / geometry.size.width))
                                    value.wrappedValue = round(percent * 10)
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
            return Color.yellow
        case 7...8:
            return Color.orange
        default:
            return Color.red
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
    }
}

struct PainScaleView_Previews: PreviewProvider {
    static var previews: some View {
        PainScaleView()
    }
}



