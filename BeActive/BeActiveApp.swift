//
//  BeActiveApp.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

//import SwiftUI
//import Firebase
//
//@main
//struct BeActiveApp: App {
//    @StateObject var manager = HealthManager()
//    @AppStorage("isLoggedIn") private var isLoggedIn = false // ✅ เช็คสถานะล็อกอิน
//
//    init() {
//        FirebaseApp.configure() // ✅ Initialize Firebase
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            if isLoggedIn {
//                MainTab() // ✅ ถ้าล็อกอินแล้ว แสดง MainTab
//                    .environmentObject(ScoreManager.shared)
//                    .environmentObject(HealthManager())
//                    .environmentObject(ThemeManager())
//            } else {
//                Login() // ✅ ถ้ายังไม่ล็อกอิน ให้แสดงหน้า Login
//                    .environmentObject(ScoreManager.shared)
//                    .environmentObject(HealthManager())
//                    .environmentObject(ThemeManager())
//            }
//        }
//    }
//}

import SwiftUI
import Firebase

@main
struct BeActiveApp: App {
    @StateObject var manager = HealthManager()
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    init() {
        FirebaseApp.configure()

        // ✅ Force logout every time app starts
//        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTab()
                    .environmentObject(ScoreManager.shared)
                    .environmentObject(HealthManager())
                    
            } else {
                Login()
                    .environmentObject(ScoreManager.shared)
                    .environmentObject(HealthManager())
                    
            }
        }
    }
}
