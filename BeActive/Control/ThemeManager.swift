//
//  ThemeManager.swift
//  BeActive
//
//  Created by Kasin Thappawan on 6/1/2568 BE.
//

//import SwiftUI
//
//class ThemeManager: ObservableObject {
//    @Published var backgroundColor: Color = .white
//    @Published var textColor: Color = .black
//    
//    private var timer: Timer?
//    
//    init() {
//        updateTheme()
//        startTimer()
//    }
//    
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            self.updateTheme()
//        }
//    }
//    
//    private func updateTheme() {
//        let hour = Calendar.current.component(.hour, from: Date())
//        
//        if hour >= 18 || hour < 6 {
//            withAnimation(.easeInOut(duration: 1)) {
//                self.backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.1)
//                self.textColor = .white
//            }
//        } else {
//            withAnimation(.easeInOut(duration: 1)) {
//                self.backgroundColor = .white
//                self.textColor = .black
//            }
//        }
//    }
//    
//    deinit {
//        timer?.invalidate()
//    }
//}
