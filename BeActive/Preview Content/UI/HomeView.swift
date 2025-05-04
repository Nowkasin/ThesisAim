//
//  HomeView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @ObservedObject var language = Language.shared
    @EnvironmentObject var manager: HealthManager

    @AppStorage("currentUserId") private var currentUserId: String = ""
    private let db = Firestore.firestore()

    @State private var userName: String = "Welcome"
    @State private var pushedScore: Int = 0
    @State private var showPushedScore: Bool = false
    @State private var scoreRefreshTimer: Timer? = nil

    var firstName: String {
        userName.components(separatedBy: " ").first ?? userName
    }

    var welcomeArray: [String] {
        [
            t("Hey, Good to see you!", in: "home_screen"),
            t("Khun", in: "home_screen") + " \(firstName)"
        ]
    }

    @State private var currentIndex = 0
    @State private var welcomeTimer: Timer?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isShowingSettings = false
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    buildHomeContent()

                    if isShowingSettings {
                        ZStack(alignment: .trailing) {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isShowingSettings = false
                                    }
                                }

                            SettingsView(isShowing: $isShowingSettings)
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.85)
                                .background(Color(.systemBackground))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .transition(.move(edge: .trailing))
                                .padding(.bottom, 20)
                                .zIndex(1)
                        }
                    }
                }
                .onAppear {
                    updateScreenWidth()
                    fetchUserData()
                    startScoreRefreshTimer()
                    ScoreManager.shared.resetTotalScoreIfNewDay()
                }
                .onDisappear {
                    stopScoreRefreshTimer()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    updateScreenWidth()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func fetchUserData() {
        guard !currentUserId.isEmpty else {
            print("❌ currentUserId is empty")
            return
        }

        db.collection("users").document(currentUserId).getDocument { document, error in
            if let error = error {
                print("❌ Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = document, let data = document.data() else {
                print("❌ User document not found or has no data")
                return
            }

            DispatchQueue.main.async {
                if let name = data["name"] as? String {
                    self.userName = name
                }

                if let score = data["score"] as? Int {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.pushedScore = score
                        self.showPushedScore = true
                    }
                }
            }
        }
    }

    func updateScreenWidth() {
        screenWidth = UIScreen.main.bounds.width
    }

    func buildHomeContent() -> some View {
        ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        ScrollView {
            VStack(alignment: .leading) {
                buildHeader()
                
                Text(getFormattedDate())
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                    .foregroundColor(getDayColor())
                    .padding(.horizontal)
                
                if showPushedScore {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 14))
                        Text("\(pushedScore)")
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: pushedScore)
                }
                
                Spacer().frame(height: DeviceHelper.adaptiveSpacing(baseSpacing: 20))
                
                TabCardControlView()
                    .environmentObject(manager)
                
                Spacer().frame(height: DeviceHelper.adaptiveSpacing(baseSpacing: 20))
                
                buildReminders()
                Color.clear.frame(height: 80)
            }
        }
        .onAppear { requestNotificationPermission() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func buildHeader() -> some View {
        HStack {
            Text("\(welcomeArray[currentIndex])")
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: DeviceHelper.adaptiveFontSize(baseSize: 32)))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .onAppear { startWelcomeTimer() }

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingSettings.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.top, DeviceHelper.adaptivePadding())
    }

    func buildReminders() -> some View {
        VStack(alignment: .leading) {
            Text(t("Reminders", in: "home_screen"))
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.bottom, 5)

            ScrollView {
                VStack(spacing: DeviceHelper.adaptiveSpacing(baseSpacing: 15)) {
                    ReminderCard(
                        title: t("Task to Complete", in: "home_screen"),
                        icon: Image(systemName: "exclamationmark.bubble.fill"),
                        color: .jasmineYellow,
                        destination: AnyView(TaskView())
                    )
                    ReminderCard(
                        title: t("Exercise", in: "home_screen"),
                        icon: Image(systemName: "figure.strengthtraining.functional.circle.fill"),
                        color: .tropicalPurple,
                        destination: AnyView(ExerciseView(language: Language.shared))
                    )
                    ReminderCard(
                        title: t("Water to Drink", in: "home_screen"),
                        icon: Image(systemName: "drop.fill"),
                        color: .pastelBlue,
                        destination: AnyView(WaterView())
                    )
                    ReminderCard(
                        title: t("Breathing Technique", in: "home_screen"),
                        icon: Image(systemName: "wind"),
                        color: .pastelOrange,
                        destination: AnyView(BreathingView())
                    )
                    ReminderCard(
                        title: t("Voucher Shop", in: "home_screen"),
                        icon: Image(systemName: "ticket.fill"),
                        color: .salmonPink,
                        destination: AnyView(VoucherView())
                    )
                    ReminderCard(
                        title: t("Mates Shop", in: "home_screen"),
                        icon: Image(systemName: "cart"),
                        color: .magicMint,
                        destination: AnyView(MatesView())
                    )

                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }

    func startWelcomeTimer() {
        welcomeTimer?.invalidate()
        welcomeTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % welcomeArray.count
            }
        }
    }

    func startScoreRefreshTimer() {
        stopScoreRefreshTimer()
        scoreRefreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            fetchUserData()
        }
    }

    func stopScoreRefreshTimer() {
        scoreRefreshTimer?.invalidate()
        scoreRefreshTimer = nil
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

    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Language.shared.currentLanguage == "th" ? "th_TH" : "en_US")
        dateFormatter.dateFormat = "EEEE"
        let dayName = dateFormatter.string(from: Date())
        let translatedDayName = t(dayName, in: "Date")

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

struct ReminderCard: View {
    var title: String
    var icon: Image
    var color: Color
    var destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                icon
                    .foregroundColor(.white)
                    .font(.system(size: 28))
                    .padding(.trailing, 8)
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)

                Text(title)
                    .foregroundColor(.white)
                    .font(.custom(Language.shared.currentLanguage == "th" ? "Kanit-SemiBold" : "RobotoCondensed-SemiBold", size: 17))
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold)) // Increased size
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
            }
            .padding()
            .background(color)
            .cornerRadius(DeviceHelper.adaptiveCornerRadius(baseRadius: 12))
            .shadow(radius: 4)
            .padding(.horizontal, DeviceHelper.adaptivePadding())
            .padding(.bottom, DeviceHelper.adaptiveSpacing(baseSpacing: 8)) // Add spacing between cards
        }
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
