//
//  HomeView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI
import UserNotifications

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager
    let welcomeArray = ["Welcome", "Bienvenido", "Bienvenue"]
    @State private var currentIndex = 0
    @State private var welcomeTimer: Timer? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = "Home"

    var body: some View {
        TabView(selection: $selectedTab) {
            ZStack {
                VStack(alignment: .leading) {
                    // Welcome message and date
                    VStack(alignment: .leading) {
                        Text("Hey, User")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        Text(getFormattedDate())
                            .font(.system(size: 16))
                            .foregroundColor(Color.accentColor) // Use system accent color
                            .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    // Today Activities section
                    Text("Today Activities")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TodayActivitiesView(manager: _manager)
                    
                    Spacer().frame(height: 5)
                    
                    // Reminders section
                    Text("Reminders")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom, 5)

                    VStack(spacing: 15) {
                        ReminderSection(title: "Task to Complete", color: .yellow)
                        ReminderSection(title: "Water to Drink", color: .blue)
                        ReminderSection(title: "Voucher Shop", color: .red)
                        ReminderSection(title: "Mates Shop", color: .green)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .onAppear {
                    startWelcomeTimer()
                    requestNotificationPermission()
                }
                .onReceive(manager.objectWillChange) { _ in
                    // UI updates handled through @Published in HealthManager
                }
                .onReceive(NotificationCenter.default.publisher(for: .moveAlert)) { notification in
                    if let message = notification.object as? String {
                        self.alertMessage = message
                        self.showAlert = true
                        triggerNotification(message: message)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Time to Move!"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            manager.handleAlertDismiss()
                        }
                    )
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
    
    // Timer function for rotating welcome messages
    func startWelcomeTimer() {
        welcomeTimer?.invalidate()
        welcomeTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % welcomeArray.count
            }
        }
    }
    
    // Request notification permission
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
        dateFormatter.dateFormat = "EEEE - dd/MM/yyyy" // Day name and date format
        return dateFormatter.string(from: Date()) // Current date
    }

    // Trigger a local notification
    func triggerNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
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

// Custom ReminderSection view that includes title and ReminderCard
struct ReminderSection: View {
    var title: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            ReminderCard(color: color)
        }
    }
}

// TodayActivitiesView for activity cards
struct TodayActivitiesView: View {
    @EnvironmentObject var manager: HealthManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 1) {
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                    ActivityCard(activity: item.value)
                        .frame(width: 200, height: 180) // Adjusted card size
                }
            }
            .padding(.horizontal)
        }
    }
}

// ReminderCard for reminder items
struct ReminderCard: View {
    var color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity, minHeight: 60)
            .cornerRadius(10)
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HealthManager())
    }
}

// Notification Name extension for move alerts
extension Notification.Name {
    static let moveAlert = Notification.Name("moveAlert")
}
