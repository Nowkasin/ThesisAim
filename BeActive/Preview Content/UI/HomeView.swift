//
//  HomeView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI

struct HomeView: View {
    @StateObject var themeManager = ThemeManager()
    @EnvironmentObject var manager: HealthManager
    let welcomeArray = ["Hello", "Bienvenido", "Wassup"]
    @State private var currentIndex = 0
    @State private var welcomeTimer: Timer?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = "Home"
    @State private var isShowingSettings = false
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
// ตัว init กำหนดสี TabView
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // DeviceHelper ตัวกำหนดขนาดอุปกรณ์ที่ใช้โดยตรวจสอบว่าเป็น Ipad หรือไม่
                    if DeviceHelper.isTablet {
                        VStack(spacing: 0) {
                            Group {
                                switch selectedTab {
                                case "Profile":
                                    ProfileView()
                                case "Content":
                                    ContentView()
                                default:
                                    buildHomeContent()
                                }
                            }
                            .id(selectedTab)
                            // เรียกใช้ Tab ที่กำหนดขนาด
                            CustomTabBar(selectedTab: $selectedTab)
                                .frame(height: 60)
                                .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                                .edgesIgnoringSafeArea(.bottom)
                        }
                    } else {
                        Color(red: 0.7, green: 0.9, blue: 1.0)
                            .edgesIgnoringSafeArea(.all)

                        TabView(selection: $selectedTab) {
                            buildHomeContent()
                                .tabItem {
                                    Image(systemName: "house")
                                    Text("Home")
                                }
                                .tag("Home")

                            ProfileView()
                                .tabItem {
                                    Image(systemName: "person.crop.circle")
                                    Text("Profile")
                                }
                                .tag("Profile")

                            ContentView()
                                .tabItem {
                                    Image(systemName: "person")
                                    Text("Content")
                                }
                                .tag("Content")
                        }
                        .background(Color.clear)
                        .edgesIgnoringSafeArea(.bottom)
                    }
                    // เรียกใช้หน้า SettingView
                    if isShowingSettings {
                        ZStack(alignment: .trailing) {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isShowingSettings = false
                                    }
                                }

                            SettingsView(isShowing: $isShowingSettings)
                                .frame(width: DeviceHelper.isTablet ? geometry.size.width * 0.25 : geometry.size.width * 0.5,
                                       height: geometry.size.height * 0.85)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .transition(.move(edge: .trailing))
                                .padding(.bottom, 20)
                                .zIndex(1)
                        }
                    }
                }
                .onAppear { updateScreenWidth() }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    updateScreenWidth()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
// อัปเดตขนาดหน้าจอที่ใช้่ เพื่อคำนวณอัตโนมัติ
    func updateScreenWidth() {
        screenWidth = UIScreen.main.bounds.width
    }
    
    func buildHomeContent() -> some View {
        ZStack {
            themeManager.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                buildHeader()
                
                Text(getFormattedDate())
                    .font(.system(size: 16))
                    .foregroundColor(getDayColor())
                    .padding(.horizontal)
                
                Spacer().frame(height: DeviceHelper.adaptiveSpacing(baseSpacing: 20))
                
                TabCardControlView(textColor: themeManager.textColor)
                    .environmentObject(manager)
                
                Spacer().frame(height: DeviceHelper.adaptiveSpacing(baseSpacing: 20))
                
                buildReminders()
                
                Spacer()
            }
            .onAppear { requestNotificationPermission() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func buildHeader() -> some View {
        HStack {
            Text("Hey \(welcomeArray[currentIndex])")
                .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 32), weight: .bold))
                .foregroundColor(themeManager.textColor)
                .onAppear { startWelcomeTimer() }

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingSettings.toggle()
                }
            }) {
                // ปุ่มขีด 3 ขีด
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(themeManager.textColor)
            }
        }
        .padding(.horizontal)
        .padding(.top, DeviceHelper.adaptivePadding())
    }
    
    func buildReminders() -> some View {
        VStack(alignment: .leading) {
            Text(t("Reminders", in: "home_screen"))
                .font(.headline)
                .foregroundColor(themeManager.textColor)
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            ScrollView {
                VStack(spacing: DeviceHelper.adaptiveSpacing(baseSpacing: 15)) {
                    ReminderSection(title: t("Task to Complete", in: "home_screen"), color: .yellow, icon: Image(systemName: "exclamationmark.bubble.fill"), textColor: themeManager.textColor)
                        .navigate(to: TaskView())
                    
                    ReminderSection(title: t("Exercise", in: "home_screen"), color: .purple, icon: Image(systemName: "figure.strengthtraining.functional.circle.fill"), textColor: themeManager.textColor)
                        .navigate(to: ExerciseView())
                    
                    ReminderSection(title: t("Water to Drink", in: "home_screen"), color: .blue, icon: Image(systemName: "drop.fill"), textColor: themeManager.textColor)
                        .navigate(to: WaterView())
                    
                    ReminderSection(title: t("Voucher Shop", in: "home_screen"), color: .red, icon: Image(systemName: "ticket.fill"), textColor: themeManager.textColor)
                        .navigate(to: VoucherView())
                    
                    ReminderSection(title: t("Mates Shop", in: "home_screen"), color: .green, icon: Image(systemName: "cart"), textColor: themeManager.textColor)
                        .navigate(to: MatesView())
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
    
    func startWelcomeTimer() {
        welcomeTimer?.invalidate()
        welcomeTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % welcomeArray.count
            }
        }
    }
    
    func dynamicPadding(for width: CGFloat) -> CGFloat {
        return width > 600 ? 40 : 20
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    //แก้ไขเวลา
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Language.shared.currentLanguage == "th" ? "th_TH" : "en_US") // เปลี่ยน locale ตามภาษา
        dateFormatter.dateFormat = "EEEE" // เอาเฉพาะชื่อวันก่อน
        let dayName = dateFormatter.string(from: Date()) // ได้ค่าเป็น "Monday" หรือ "วันจันทร์"
        
        // ใช้ t() เพื่อแปลชื่อวัน
        let translatedDayName = t(dayName, in: "Date")
        
        // ฟอร์แมตวันที่
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: Date())
        
        return "\(translatedDayName) - \(dateString)"
    }
    
    func getDayColor() -> Color {
        let colors: [Color] = [.red, .yellow, .pink, .green, .orange, .blue, .purple]
        let weekday = Calendar.current.component(.weekday, from: Date()) - 1
        return colors[weekday]
    }
    
    func triggerNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = (t("Time to Move!", in: "home_screen"))
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error triggering notification: \(error.localizedDescription)")
            }
        }
    }
}


struct ReminderSection: View {
    var title: String
    var color: Color
    var icon: Image
    var textColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                icon
                    .foregroundColor(color)
                    .font(.system(size: 20))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(textColor)
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            ReminderCard(color: color)
        }
    }
}

struct ReminderCard: View {
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: DeviceHelper.adaptiveCornerRadius(baseRadius: 12))
            .fill(color)
            .frame(maxWidth: .infinity, minHeight: DeviceHelper.adaptiveFrameSize(baseSize: 60))
            .shadow(radius: 4)
            .padding(.horizontal, DeviceHelper.adaptivePadding())
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
    }
}

extension Notification.Name {
    static let moveAlert = Notification.Name("moveAlert")
}

extension View {
    func navigate<Destination: View>(to destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            self
        }
    }
}
