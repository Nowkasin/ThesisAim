//
//  BeActiTabView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI

struct BeActiTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    
    init() {
        // กำหนดสีพื้นหลังของ tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .environmentObject(manager)
            
            ProfileView()
                .tag("Profile")
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
            
            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "person")
                    Text("Content")
                }
        }
        .background(Color(red: 0.7, green: 0.9, blue: 1.0)) // เปลี่ยนพื้นหลังของ TabView
        .navigationBarHidden(true) // ซ่อน Navigation Bar
    }
}

struct BeActiTabView_Previews: PreviewProvider {
    static var previews: some View {
        BeActiTabView()
            .environmentObject(HealthManager())  // Provide the environment object for preview
    }
}
