//
//  BeActiveApp.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI
import Firebase


@main
struct BeActiveApp: App {
    @StateObject var manager = HealthManager()
    
    init() {
        FirebaseApp.configure() // Initialize Firebase
    }
    
    var body: some Scene {
        WindowGroup {
            Login()
                .environmentObject(HealthManager())// Make sure this is correctly applied
                .environmentObject(ThemeManager())
        }
    }
}

