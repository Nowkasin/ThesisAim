//
//  BeActiTabView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//
//
import SwiftUI

struct BeActiTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if DeviceHelper.isTablet {
                    VStack(spacing: 0) {
                        Group {
                            switch selectedTab {
                            case "Home":
                                HomeView()
                            case "Profile":
                                ProfileView()
                            case "Content":
                                ContentView()
                            default:
                                HomeView()
                            }
                        }
                        .id(selectedTab)

                        CustomTabBar(selectedTab: $selectedTab)
                            .frame(height: 60)
                            .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                            .edgesIgnoringSafeArea(.bottom)
                    }
                } else {
                    ZStack {
                        Color(red: 0.7, green: 0.9, blue: 1.0)
                            .edgesIgnoringSafeArea(.all)

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
                        .background(Color.clear)
                        .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
            .onAppear { updateScreenWidth() }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                updateScreenWidth()
            }
        }
        .navigationBarHidden(true)
    }

    func updateScreenWidth() {
        screenWidth = UIScreen.main.bounds.width
    }
}

// ✅ CustomTabBar รองรับการเปลี่ยน UI ตามขนาดจอ
struct CustomTabBar: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack {
            Spacer()
            TabBarItem(title: "Home", icon: "house", selectedTab: $selectedTab)
            Spacer()
            TabBarItem(title: "Profile", icon: "person.crop.circle", selectedTab: $selectedTab)
            Spacer()
            TabBarItem(title: "Content", icon: "person", selectedTab: $selectedTab)
            Spacer()
        }
        .frame(height: 60)
        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
        .edgesIgnoringSafeArea(.bottom)
    }
}

// ✅ TabBarItem รองรับ Adaptive UI
struct TabBarItem: View {
    let title: String
    let icon: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            selectedTab = title
        }) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DeviceHelper.adaptiveFrameSize(baseSize: 24), height: DeviceHelper.adaptiveFrameSize(baseSize: 24))
                    .foregroundColor(selectedTab == title ? .blue : .gray)
                
                Text(title)
                    .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 14), weight: .medium))
                    .foregroundColor(selectedTab == title ? .blue : .gray)
            }
        }
    }
}

struct BeActiTabView_Previews: PreviewProvider {
    static var previews: some View {
        BeActiTabView()
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
    }
}
