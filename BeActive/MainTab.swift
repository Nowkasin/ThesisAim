//
//  MainTab.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/3/2568 BE.
//

import SwiftUI

struct MainTab: View {
    @EnvironmentObject var manager: HealthManager
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
                        switch selectedTab {
                        case 0:
                            HomeView()
                                .id(homeRefreshID) // ✅ ใช้ UUID เพื่อรีโหลด HomeView
                                .transition(.opacity.combined(with: .scale)) // ✅ เพิ่ม Animation
                        case 1:
                            ProfileView()
                                .transition(.slide)
                        case 2:
                            ContentView()
                                .transition(.move(edge: .trailing))
                        default:
                            HomeView()
                                .id(homeRefreshID)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // ✅ CustomTabBar สำหรับ iPad
                    CustomTabBar(selectedTab: $selectedTab, homeRefreshID: $homeRefreshID)
                        .frame(height: 60)
                        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                }
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .id(homeRefreshID)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)

                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.crop.circle")
                            Text("Profile")
                        }
                        .tag(1)

                    ContentView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Content")
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
            TabBarItem(title: "Home", icon: "house", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 0)
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
            withAnimation(.easeInOut(duration: 0.3)) { // ✅ ใช้ Animation ตอนเปลี่ยนแท็บ
                if selectedTab == tag && tag == 0 {
                    // ✅ ถ้ากด Home ซ้ำ ให้รีเซ็ต HomeView พร้อม Animation
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

