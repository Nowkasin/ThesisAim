//
//  WaterView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 4/11/2567 BE.
//

import SwiftUI

struct WaterView: View {
    @Environment(\.presentationMode) var presentationMode // For navigation control
    @State private var waterIntake = 0 // Current water intake
    private let totalWaterIntake = 2100 // Total daily goal
    @State private var schedule = [
        (time: "09:30", amount: 500, completed: false),
        (time: "11:30", amount: 500, completed: false),
        (time: "13:30", amount: 500, completed: false),
        (time: "15:30", amount: 500, completed: false),
        (time: "17:30", amount: 100, completed: false),
    ]
    @State private var showCongratulations = false // State for popup visibility
    
    var body: some View {
        NavigationView {
            VStack {
                // Header Section
                VStack(spacing: 8) {
                    Text("Water to Drink")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Don't forget to drink water!")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                Spacer()
                
                // Water Level Section
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .foregroundColor(.blue.opacity(0.3))
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(Double(waterIntake) / Double(totalWaterIntake)))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: waterIntake)
                    
                    VStack {
                        Text("\(waterIntake) / \(totalWaterIntake)")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                        
                        Image(systemName: "drop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 200, height: 200)
                
                Spacer()
                
                // Water Schedule Section
                VStack(alignment: .leading) {
                    ForEach(0..<schedule.count, id: \.self) { index in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text(schedule[index].time)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(schedule[index].amount) ml")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            Button(action: {
                                // Toggle completion
                                schedule[index].completed.toggle()
                                if schedule[index].completed {
                                    waterIntake += schedule[index].amount
                                } else {
                                    waterIntake -= schedule[index].amount
                                }
                                
                                // Check if all checkmarks are selected
                                if schedule.filter({ $0.completed }).count == schedule.count {
                                    showCongratulations = true
                                }
                            }) {
                                Image(systemName: schedule[index].completed ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(schedule[index].completed ? .green : .gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showCongratulations) {
                Alert(
                    title: Text("Congratulations!"),
                    message: Text("You have completed your daily water schedule!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WaterView()
}

