//
//  HomeView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager

    @AppStorage("currentUserId") private var currentUserId: String = ""
    private let db = Firestore.firestore()

    @State private var userName: String = "Welcome"

    var firstName: String {
        userName.components(separatedBy: " ").first ?? userName
    }

    var welcomeArray: [String] {
        [firstName, "Wassup"]
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
                    fetchUserName()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    updateScreenWidth()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func fetchUserName() {
        guard !currentUserId.isEmpty else {
            print("❌ currentUserId is empty")
            return
        }

        db.collection("users").document(currentUserId).getDocument { document, error in
            if let error = error {
                print("❌ Error fetching user name: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data(), let name = data["name"] as? String {
                DispatchQueue.main.async {
                    self.userName = name
                }
            } else {
                print("❌ User document not found or name is missing")
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

            VStack(alignment: .leading) {
                buildHeader()

                Text(getFormattedDate())
                    .font(.system(size: 16))
                    .foregroundColor(getDayColor())
                    .padding(.horizontal)

                Spacer().frame(height: DeviceHelper.adaptiveSpacing(baseSpacing: 20))

                TabCardControlView()
                    .environmentObject(manager)

                Spacer().frame(height: DeviceHelper.adaptiveSpacing(baseSpacing: 20))

                buildReminders()
            }
            .onAppear { requestNotificationPermission() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func buildHeader() -> some View {
        HStack {
            Text("Hey \(welcomeArray[currentIndex])")
                .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 32), weight: .bold))
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
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.bottom, 5)

            ScrollView {
                VStack(spacing: DeviceHelper.adaptiveSpacing(baseSpacing: 15)) {
                    ReminderSection(title: t("Task to Complete", in: "home_screen"), color: .jasmineYellow, icon: Image(systemName: "exclamationmark.bubble.fill"))
                        .navigate(to: TaskView())

                    ReminderSection(title: t("Exercise", in: "home_screen"), color: .tropicalPurple, icon: Image(systemName: "figure.strengthtraining.functional.circle.fill"))
                        .navigate(to: ExerciseView())

                    ReminderSection(title: t("Water to Drink", in: "home_screen"), color: .pastelBlue, icon: Image(systemName: "drop.fill"))
                        .navigate(to: WaterView())

                    ReminderSection(title: t("Voucher Shop", in: "home_screen"), color: .salmonPink, icon: Image(systemName: "ticket.fill"))
                        .navigate(to: VoucherView())

                    ReminderSection(title: t("Mates Shop", in: "home_screen"), color: .magicMint, icon: Image(systemName: "cart"))
                        .navigate(to: MatesView())
                }
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

struct ReminderSection: View {
    var title: String
    var color: Color
    var icon: Image

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                icon
                    .foregroundColor(color)
                    .font(.system(size: 20))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
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
