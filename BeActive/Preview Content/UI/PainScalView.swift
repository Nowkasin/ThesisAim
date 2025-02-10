//
//  PainScalView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 7/2/2568 BE.
//

//import SwiftUI
//
//struct PainScaleView: View {
//    @State private var headPain: Double = 1
//    @State private var armPain: Double = 4
//    @State private var shoulderPain: Double = 9
//    @State private var backPain: Double = 5
//    @State private var legPain: Double = 3
//    @State private var footPain: Double = 2
//    
//    let painColors: [Color] = [.blue, .green, .green, .green, .yellow, .yellow, .orange, .orange, .red, .red, .black]
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Button(action: { /* Add back action */ }) {
//                    Image(systemName: "chevron.left")
//                        .font(.title)
//                        .foregroundColor(.black)
//                }
//                Spacer()
////                Button(action: { /* Add menu action */ }) {
////                    Image(systemName: "face.smiling.inverse")
////                        .font(.title)
////                        .foregroundColor(.black)
////                }
//            }
//            .padding()
//            
//            Text("Pain Sale")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.pink)
//            
//            PainScaleLegend()
//                .padding(.top, 10)
//            
//            PainSlider(label: "Head", value: $headPain, color: painColors[Int(headPain)])
//            PainSlider(label: "Arm", value: $armPain, color: painColors[Int(armPain)])
//            PainSlider(label: "Shoulder", value: $shoulderPain, color: painColors[Int(shoulderPain)])
//            PainSlider(label: "Back", value: $backPain, color: painColors[Int(backPain)])
//            PainSlider(label: "Leg", value: $legPain, color: painColors[Int(legPain)])
//            PainSlider(label: "Foot", value: $footPain, color: painColors[Int(footPain)])
//            
//            Spacer()
//            
//
//        }
//        .padding()
//    }
//}
//
//struct PainScaleLegend: View {
//    let levels: [String] = [
//        "https://img.icons8.com/?size=100&id=7868&format=png&color=22C3E6",
//        "https://img.icons8.com/?size=100&id=7850&format=png&color=000000"
//
//    ]
//    
//    var body: some View {
//        VStack {
//            HStack(spacing: 5) {
//                ForEach(0..<levels.count, id: \ .self) { index in
//                    VStack {
//                        if let url = URL(string: levels[index]) {
//                            AsyncImage(url: url)
//                                .frame(width: 50, height: 50)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct PainSlider: View {
//    let label: String
//    @Binding var value: Double
//    let color: Color
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(label)
//                .font(.headline)
//            Slider(value: $value, in: 0...10, step: 1)
//                .accentColor(color)
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//
//
//
//struct PainScaleView_Previews: PreviewProvider {
//    static var previews: some View {
//        PainScaleView()
//    }
//}

//ให้สร้างตัวแปรแต่ละตัว ให้เก็บค่าในแต่ละส่วน
