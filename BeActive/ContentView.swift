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
    @State private var userAge: Int? = nil

    func addUser() {
        db.collection("users").document("user1").setData([
            "name": "John Doe",
            "age": 25
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    func getUser() {
        db.collection("users").document("user1").getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let name = data?["name"] as? String, let age = data?["age"] as? Int {
                    DispatchQueue.main.async { // Update UI on the main thread
                        self.userName = name
                        self.userAge = age
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.userName = "No user found"
                    self.userAge = nil
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("User Name: \(userName)")
                .font(.title)
                .padding()
            
            if let age = userAge {
                Text("User Age: \(age)")
                    .font(.headline)
            }

            Button("Add User") {
                addUser()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Get User") {
                getUser()
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


