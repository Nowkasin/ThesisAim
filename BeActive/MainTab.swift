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
    @State private var languageUpdateTrigger = false
    @ObservedObject var language = Language.shared

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            switch selectedTab {
            case 0:
                HomeView().id(homeRefreshID)
            case 1:
                ProfileView().environmentObject(healthData)
            case 2:
                PainScaleView()
            default:
                HomeView().id(homeRefreshID)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 80)
        }
        .overlay(
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, homeRefreshID: $homeRefreshID)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
        )
        .onReceive(language.objectWillChange) { _ in
            languageUpdateTrigger.toggle()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var homeRefreshID: UUID
    @ObservedObject var language = Language.shared

    var body: some View {
        HStack {
            TabBarItem(title: t("Home", in: "MainTab_screen"), icon: "house.fill", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 0)
            Spacer()
            TabBarItem(title: t("Profile", in: "MainTab_screen"), icon: "person.crop.circle", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 1)
            Spacer()
            TabBarItem(title: t("Pain Scale", in: "MainTab_screen"), icon: "quotelevel", selectedTab: $selectedTab, homeRefreshID: $homeRefreshID, tag: 2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
            if selectedTab == tag && tag == 0 {
                homeRefreshID = UUID()
            } else {
                selectedTab = tag
            }
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
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
