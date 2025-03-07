import SwiftUI
import UserNotifications

struct HomeView: View {
    @StateObject var themeManager = ThemeManager()  // ใช้ @StateObject เพื่อให้ ThemeManager ถูกสร้างครั้งเดียว
    @EnvironmentObject var manager: HealthManager
    let welcomeArray = ["Hello", "Bienvenido", "Wassup"]
    @State private var currentIndex = 0
    @State private var welcomeTimer: Timer?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = "Home"
    @State private var isShowingSettings = false // ตัวแปรควบคุมการแสดงผล Settings
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                TabView(selection: $selectedTab) {
                    ZStack {
                        themeManager.backgroundColor
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Hey \(welcomeArray[currentIndex])")
                                    .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                                    .foregroundColor(themeManager.textColor)
                                    .onAppear {
                                        startWelcomeTimer()
                                    }
                                
                                Spacer() // ดันไอคอนไปด้านขวา
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 1)) { // ใช้ easeInOut และกำหนดระยะเวลา 0.5 วินาที
                                        isShowingSettings.toggle()
                                    }
                                }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.title2)
                                        .foregroundColor(themeManager.textColor)
                                }

                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            Text(getFormattedDate())
                                .font(.system(size: 16))
                                .foregroundColor(getDayColor())
                                .padding(.horizontal)
                            
                            Spacer().frame(height: geometry.size.height * 0.01)
                            
                            TodayActivitiesView(manager: _manager, textColor: themeManager.textColor)
                            
                            Spacer().frame(height: geometry.size.height * 0.01)
                            
                            Text(t("Reminders", in: "home_screen"))
                                .font(.headline)
                                .foregroundColor(themeManager.textColor)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            
                            ScrollView {
                                VStack(spacing: 15) {
                                    // แปลภาษาให้ด้วย
                                    ReminderSection(title: t("Task to Complete", in: "home_screen"), color: .jasmineYellow, icon: Image(systemName: "exclamationmark.bubble.fill"), textColor: themeManager.textColor)
                                        .navigate(to: TaskView())
                                    
                                    // แปลภาษาให้ด้วย
                                    ReminderSection(title: t("Exercise", in: "home_screen"), color: .tropicalPurple, icon: Image(systemName: "figure.strengthtraining.functional.circle.fill"), textColor: themeManager.textColor)
                                        .navigate(to: ExerciseView())
                                    
                                    ReminderSection(title: t("Water to Drink", in: "home_screen"), color: .pastelBlue, icon: Image(systemName: "drop.fill"), textColor: themeManager.textColor)
                                        .navigate(to: WaterView())

                                    ReminderSection(title: t("Voucher Shop", in: "home_screen"), color: .salmonPink, icon: Image(systemName: "ticket.fill"), textColor: themeManager.textColor)
                                        .navigate(to: VoucherView())

                                    ReminderSection(title: t("Mates Shop", in: "home_screen"), color: .magicMint, icon: Image(systemName: "cart"), textColor: themeManager.textColor)
                                        .navigate(to: MatesView())
                                }
                                .padding()
                            }

                            .padding(.horizontal)
                            Spacer()
                        }
                        .onAppear {
                            requestNotificationPermission()
                        }
                        .onReceive(manager.objectWillChange) { _ in }
                        .onReceive(NotificationCenter.default.publisher(for: .moveAlert)) { notification in
                            if let message = notification.object as? String {
                                self.alertMessage = message
                                self.showAlert = true
                                triggerNotification(message: message)
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text(t("Time to Move!", in: "home_screen")),
                                message: Text(alertMessage),
                                dismissButton: .default(Text(t("OK", in: "home_screen"))) {
                                    manager.handleAlertDismiss()
                                }
                            )
                        }
                        
                        // Settings Panel
                        if isShowingSettings {
                            ZStack(alignment: .trailing) { // ใช้ ZStack และจัดตำแหน่งให้อยู่ด้านขวา
                                Color.black.opacity(0.4) // เพิ่มพื้นหลังโปร่งแสง
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        withAnimation {
                                            isShowingSettings = false
                                        }
                                    }
                                
                                SettingsView(isShowing: $isShowingSettings)
                                    .frame(width: geometry.size.width * 0.5) // แสดงครึ่งหน้าจอ
                                    .background(Color.white)
                                    .transition(.move(edge: .trailing)) // เลื่อนจากด้านขวา
                                    .zIndex(1)
                            }
                        }
                    }
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag("Home")
                    
                    ContentView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Content")
                        }
                        .tag("Content")
                }
            }
            .navigationBarHidden(true)
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

struct TodayActivitiesView: View {
    @EnvironmentObject var manager: HealthManager
    var textColor: Color
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(t("Today Activities", in: "home_screen"))
                    .font(.headline)
                    .foregroundColor(textColor)
                Spacer()
                HStack {
                    Image(systemName: "star.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.yellow)
                    Text("\(manager.stepScore+manager.waterScore)")
                        .font(.headline)
                        .padding(8)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                        ActivityCard(activity: item.value)
                            .frame(width: 200, height: 180)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ReminderCard: View {
    var color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity, minHeight: 60)
            .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HealthManager())
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
