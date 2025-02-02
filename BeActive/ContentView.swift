//
//  ContentView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 29/5/2567 BE.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    let db = Firestore.firestore()
    
    @State private var userName: String = "No user data"
    @State private var userAge: Int?
    @State private var userEmail: String = "No email"
    @State private var userHeight: Int?
    @State private var userPhone: String = "No phone" // Store as a String
    @State private var userSex: String = "No sex info"
    @State private var userWeight: Int?
    @State private var errorMessage: String? // Handle errors

    func addUser() {
        let userData: [String: Any] = [
            "name": "Kasem Thepleela",
            "age": 22,
            "email": "Kasem@gmail.com",
            "height": 180,
            "phone": "0812345678", // Store as a String to prevent formatting issues
            "sex": "Male",
            "weight": 90
        ]
        
        db.collection("users").document("user1").setData(userData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    print("Firestore Error: \(error.localizedDescription)")
                } else {
                    self.errorMessage = nil
                    print("Document successfully written!")
                }
            }
        }
    }

    func getUser() {
        db.collection("users").document("user1").getDocument { document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    print("Firestore Error: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists, let data = document.data() {
                    self.userName = data["name"] as? String ?? "No name"
                    self.userAge = data["age"] as? Int
                    self.userEmail = data["email"] as? String ?? "No email"
                    self.userHeight = data["height"] as? Int
                    self.userPhone = data["phone"] as? String ?? "No phone"
                    self.userSex = data["sex"] as? String ?? "No sex info"
                    self.userWeight = data["weight"] as? Int
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "User not found"
                    self.userName = "No user found"
                    self.userAge = nil
                    self.userEmail = "No email"
                    self.userHeight = nil
                    self.userPhone = "No phone"
                    self.userSex = "No sex info"
                    self.userWeight = nil
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 15) {
            Text("User Info")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("👤 Name: \(userName)").font(.title2)
                if let age = userAge { Text("🎂 Age: \(age)") }
                Text("📧 Email: \(userEmail)")
                if let height = userHeight { Text("📏 Height: \(height) cm") }
                Text("📞 Phone: \(userPhone)")
                Text("🎃 Sex: \(userSex)")
                if let weight = userWeight { Text("⚖️ Weight: \(weight) kg") }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding()
            }

            Spacer()

            HStack {
                Button("➕ Add User") {
                    addUser()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button("🔍 Get User") {
                    getUser()
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .padding()
    }
}

#Preview {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        return ContentViewPreview() // Mock data for Preview Mode
    } else {
        return ContentView()
    }
}

// ✅ **Mock Data for SwiftUI Preview**
struct ContentViewPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("User Info (Preview)")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("👤 Name: Preview").font(.title2)
                Text("🎂 Age: Preview")
                Text("📧 Email: Preview")
                Text("📏 Height: Preview")
                Text("📞 Phone: Preview")
                Text("🎃 Sex: Preview")
                Text("⚖️ Weight: Preview")
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)

            Spacer()

            Text("🔥 Firestore is disabled in preview mode")
                .foregroundColor(.red)
                .padding()
        }
        .padding()
    }
}



