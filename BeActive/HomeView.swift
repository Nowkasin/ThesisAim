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
    
    // State variables for the alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading) {
                Text(welcomeArray[currentIndex])
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 1), value: currentIndex)
                    .onAppear {
                        startWelcomeTimer()
                        requestNotificationPermission()
                        // ทดสอบการส่งการแจ้งเตือน
                        triggerNotification(message: "This is a test notification!")
                    }

                
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                    ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                        ActivityCard(activity: item.value)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onReceive(manager.objectWillChange) { _ in
                // UI updates handled through @Published in HealthManager
            }
            // Handle alert when receiving notifications from NotificationCenter
            .onReceive(NotificationCenter.default.publisher(for: .moveAlert)) { notification in
                if let message = notification.object as? String {
                    self.alertMessage = message
                    self.showAlert = true
                    triggerNotification(message: message) // Trigger local notification
                }
            }
            // Display the alert
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Time to Move!"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        manager.handleAlertDismiss() // Call the function correctly
                    }
                )
            }
            
            // Score badge in the top-right corner, using manager's stepScore
            VStack {
                HStack {
                    Spacer()
                    Text("Score: \(manager.stepScore)") // Use manager.stepScore here
                        .padding(8)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // Timer function for rotating welcome messages
    func startWelcomeTimer() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
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
