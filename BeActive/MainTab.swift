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
    @State private var homeRefreshID = UUID()

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
                        Color.white.edgesIgnoringSafeArea(.all)
                        switch selectedTab {
                        case 0:
                            HomeView()
                                .id(homeRefreshID)
                                .transition(.opacity.combined(with: .scale))
                        case 1:
                            ProfileView()
                                .environmentObject(healthData)
                                .transition(.identity)
                        case 2:
                            PainScaleView()
                                .transition(.move(edge: .trailing))
                        default:
                            HomeView()
                                .id(homeRefreshID)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    CustomTabBar(selectedTab: $selectedTab, homeRefreshID: $homeRefreshID)
                        .frame(height: 60)
                        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                }
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .id(homeRefreshID)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text(t("Home", in: "MainTab_screen"))
                        }
                        .tag(0)

                    ProfileView()
                        .environmentObject(healthData)
                        .tabItem {
                            Image(systemName: "person.crop.circle")
                            Text(t("Profile", in: "MainTab_screen"))
                        }
                        .tag(1)

                    PainScaleView()
                        .tabItem {
                            Image(systemName: "quotelevel")
                            Text(t("Pain Scale", in: "MainTab_screen"))
                        }
                        .tag(2)
                }
                .accentColor(.blue)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var homeRefreshID: UUID

    var body: some View {
        HStack {
            Spacer()
            TabBarItem(title: t("Home", in: "MainTab_screen"), icon: "house.fill", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 0)
            Spacer()
            TabBarItem(title: t("Profile", in: "MainTab_screen"), icon: "person.crop.circle", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 1)
            Spacer()
            TabBarItem(title: t("Pain Scale", in: "MainTab_screen"), icon: "quotelevel", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 2)
            Spacer()
        }
        .frame(height: 60)
        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
        .edgesIgnoringSafeArea(.bottom)
    }
}

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

struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab()
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
            .previewLayout(.sizeThatFits)
    }
}
