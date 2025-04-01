//
//  MainTab.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/3/2568 BE.
//

import SwiftUI

struct MainTab: View {
    @EnvironmentObject var manager: HealthManager
    @StateObject private var healthData = HealthDataManager()
    @State private var selectedTab = 0
    @State private var homeRefreshID = UUID() // ✅ ใช้ UUID เพื่อรีโหลด HomeView พร้อม Animation

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if DeviceHelper.isTablet {
                VStack(spacing: 0) {
                    ZStack {
                        Color.white.edgesIgnoringSafeArea(.all) // ✅ ป้องกันพื้นหลังดำ
                        switch selectedTab {
                        case 0:
                            HomeView()
                                .id(homeRefreshID)
                                .transition(.opacity.combined(with: .scale))
                                .onAppear { print("✅ HomeView Loaded") }
                        case 1:
                            ProfileView()
                                .environmentObject(healthData) // ✅ ใช้ EnvironmentObject เพื่อลดการรีเรนเดอร์ซ้ำ
                                .transition(.identity) // ✅ ป้องกัน Animation ไม่ให้กระพริบ
                                .onAppear { print("✅ ProfileView Loaded") }
                        case 2:
                            PainScaleView()
                                .transition(.move(edge: .trailing))
                                .onAppear { print("✅ ContentView Loaded") }
                        default:
                            HomeView()
                                .id(homeRefreshID)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3)) // ✅ ใช้ Animation ตอนเปลี่ยนแท็บ
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // ✅ CustomTabBar สำหรับ iPad
                    CustomTabBar(selectedTab: $selectedTab, homeRefreshID: $homeRefreshID)
                        .frame(height: 60)
                        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                }
            } else {
                // ✅ ใช้ TabView สำหรับ iPhone
                TabView(selection: $selectedTab) {
                    HomeView()
                        .id(homeRefreshID)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)

                    ProfileView()
                        .environmentObject(healthData) // ✅ ใช้ EnvironmentObject เพื่อลดการรีเรนเดอร์ซ้ำ
                        .tabItem {
                            Image(systemName: "person.crop.circle")
                            Text("Profile")
                        }
                        .tag(1)

                    PainScaleView()
                        .tabItem {
                            Image(systemName: "quotelevel")
                            Text("Pain Scale")
                        }
                        .tag(2)
                }
                .accentColor(.blue)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// ✅ CustomTabBar สำหรับ iPad พร้อม Animation
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var homeRefreshID: UUID

    var body: some View {
        HStack {
            Spacer()
            TabBarItem(title: "Home", icon: "house.fill", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 0)
            Spacer()
            TabBarItem(title: "Profile", icon: "person.crop.circle", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 1)
            Spacer()
            TabBarItem(title: "Content", icon: "person", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 2)
            Spacer()
        }
        .frame(height: 60)
        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
        .edgesIgnoringSafeArea(.bottom)
    }
}

// ✅ ปรับให้ Home มี Animation เมื่อกดปุ่ม Home ซ้ำ
struct TabBarItem: View {
    let title: String
    let icon: String
    @Binding var selectedTab: Int
    @Binding var homeRefreshID: UUID
    let tag: Int

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                if selectedTab == tag && tag == 0 {
                    homeRefreshID = UUID()
                } else {
                    selectedTab = tag
                }
            }
        }) {
            VStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(selectedTab == tag ? .blue : .gray)
        }
    }
}

// ✅ Preview
struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab()
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
            .previewLayout(.sizeThatFits)
    }
}

