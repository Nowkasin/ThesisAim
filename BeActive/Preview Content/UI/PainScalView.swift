//
//  PainScalView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 7/2/2568 BE.
//

import SwiftUI

struct PainSaleView: View {
    @State private var headPain: Double = 0
    @State private var armPain: Double = 5
    @State private var shoulderPain: Double = 10
    @State private var backPain: Double = 5
    @State private var legPain: Double = 3
    @State private var footPain: Double = 2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Navigation & Title
          
            
            Text("Pain Sale")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.leading)
            
            // Pain Scale Chart
            PainScaleView()
                .padding(.horizontal)
            
            // Pain Level Sliders
            PainSlider(title: "Head", value: $headPain, color: .mint)
            PainSlider(title: "Arm", value: $armPain, color: .yellow)
            PainSlider(title: "Shoulder", value: $shoulderPain, color: .red)
            PainSlider(title: "Back", value: $backPain, color: .yellow)
            PainSlider(title: "Leg", value: $legPain, color: .green)
            PainSlider(title: "Foot", value: $footPain, color: .green)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - PainSlider Component
struct PainSlider: View {
    var title: String
    @Binding var value: Double
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                Slider(value: $value, in: 0...10, step: 1)
                    .accentColor(color)
            }
        }
    }
}


struct PainLevel: Identifiable {
    let id = UUID()
    let level: Int
    let description: String
    let color: Color
}


struct PainScaleView: View {
    let painLevels: [PainLevel] = [
        PainLevel(level: 0, description: "No Pain", color: .blue),
        PainLevel(level: 1, description: "Very Mild", color: .green),
        PainLevel(level: 2, description: "Discomforting", color: .green),
        PainLevel(level: 3, description: "Tolerable", color: .green),
        PainLevel(level: 4, description: "Distressing", color: .yellow),
        PainLevel(level: 5, description: "Very Distressing", color: .yellow),
        PainLevel(level: 6, description: "Intense", color: .orange),
        PainLevel(level: 7, description: "Very Intense", color: .orange),
        PainLevel(level: 8, description: "Horrible", color: .red),
        PainLevel(level: 9, description: "Unbearable", color: .red),
        PainLevel(level: 10, description: "Unspeakable", color: .red)
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
                ForEach(painLevels) { pain in
                    VStack {
                        Circle()
                            .fill(pain.color.opacity(0.85))
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            .overlay(
                                Text("\(pain.level)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                        
                        Text(pain.description)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct PainSaleView_Previews: PreviewProvider {
    static var previews: some View {
        PainSaleView()
    }
}
