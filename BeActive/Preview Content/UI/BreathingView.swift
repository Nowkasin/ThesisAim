//
//  BreathingView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 18/4/2568 BE.
//

import SwiftUI

struct BreathingTechnique: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let pattern: [Int]
    let description: String
    let duration: Int
}

struct BreathingView: View {
    @State private var selectedTechnique: BreathingTechnique
    @State private var currentPhase = 0
    @State private var instructionText = "Ready?"
    @State private var phaseTimeLeft = 0
    @State private var totalTimeLeft = 0
    @State private var isBreathing = false
    @State private var showTechniqueSheet = false
    @State private var circleScale: CGFloat = 1.0
    @State private var timer: Timer?

    private let techniques: [BreathingTechnique] = [
        BreathingTechnique(name: "Box Breathing", pattern: [4, 4, 4, 4], description: "Balance & calm", duration: 60),
        BreathingTechnique(name: "4-7-8 Breathing", pattern: [4, 7, 8, 0], description: "Sleep better", duration: 60),
        BreathingTechnique(name: "Deep Breathing", pattern: [5, 0, 5, 0], description: "Stay relaxed", duration: 60),
        BreathingTechnique(name: "Relax & Reset", pattern: [6, 3, 6, 3], description: "Relieve tension", duration: 60),
        BreathingTechnique(name: "Energy Boost", pattern: [3, 0, 3, 0], description: "Quick recharge", duration: 60)
    ]

    init() {
        _selectedTechnique = State(initialValue: BreathingTechnique(
            name: "Box Breathing",
            pattern: [4, 4, 4, 4],
            description: "Balance & calm",
            duration: 60
        ))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(selectedTechnique.name)
                        .font(.title.bold())

                    Text(selectedTechnique.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.2))
                        .frame(width: 220, height: 220)
                        .scaleEffect(circleScale)
                        .animation(.easeInOut(duration: 1.0), value: circleScale)
                        .shadow(color: Color.teal.opacity(0.4), radius: 40)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(radius: 4)

                    VStack(spacing: 4) {
                        Text(emojiForCurrentPhase() + " " + instructionText)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.teal)

                        if isBreathing {
                            Text("\(phaseTimeLeft)s")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 30)

                // ✅ Total time moved below breathing circle
                if isBreathing {
                    Text("Total Remaining: \(totalTimeLeft)s")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 24)
                }

                Spacer()

                // Technique Dropdown (Bottom Sheet)
                Button {
                    if !isBreathing {
                        showTechniqueSheet = true
                    }
                } label: {
                    HStack {
                        Text(selectedTechnique.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)

                // Start / Stop Button
                Button(action: {
                    isBreathing ? stopBreathing() : startBreathing()
                }) {
                    Text(isBreathing ? "Stop" : "Start Now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isBreathing ? Color.red : Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 6)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .sheet(isPresented: $showTechniqueSheet) {
            VStack(spacing: 12) {
                Text("Choose Technique")
                    .font(.headline)
                    .padding(.top)

                ForEach(techniques) { technique in
                    Button(action: {
                        selectedTechnique = technique
                        showTechniqueSheet = false
                    }) {
                        HStack {
                            Text(technique.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedTechnique == technique {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onDisappear {
            stopBreathing()
        }
    }

    private func startBreathing() {
        currentPhase = 0
        totalTimeLeft = selectedTechnique.duration
        isBreathing = true
        runPhase()
    }

    private func stopBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
        instructionText = "Ready?"
        phaseTimeLeft = 0
        totalTimeLeft = 0
        circleScale = 1.0
    }

    private func runPhase() {
        guard isBreathing else { return }

        let phaseNames = ["Inhale", "Hold", "Exhale", "Hold"]
        let phaseDuration = selectedTechnique.pattern[currentPhase]
        instructionText = phaseNames[currentPhase]
        phaseTimeLeft = phaseDuration

        withAnimation {
            switch currentPhase {
            case 0: circleScale = 1.3  // Inhale
            case 2: circleScale = 0.8  // Exhale
            default: circleScale = 1.0 // Hold
            }
        }

        if phaseDuration == 0 {
            nextPhase()
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            guard isBreathing else {
                t.invalidate()
                return
            }

            phaseTimeLeft -= 1
            totalTimeLeft -= 1

            if totalTimeLeft <= 0 {
                stopBreathing()
                t.invalidate()
                return
            }

            if phaseTimeLeft <= 0 {
                t.invalidate()
                nextPhase()
            }
        }
    }

    private func nextPhase() {
        currentPhase = (currentPhase + 1) % selectedTechnique.pattern.count
        runPhase()
    }

    private func emojiForCurrentPhase() -> String {
        switch instructionText {
        case "Inhale": return "🫁"
        case "Exhale": return "💨"
        case "Hold": return "🤐"
        default: return "😌"
        }
    }
}

struct BreathingView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingView()
    }
}
