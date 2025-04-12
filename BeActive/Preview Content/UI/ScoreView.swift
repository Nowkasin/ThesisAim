//
//  ScoreView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 24/2/2568 BE.
//

import SwiftUI
import FirebaseFirestore

struct ScoreView: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("lastScoreUploadDate") private var lastScoreUploadDate: String = ""

    @State private var showAlert = false
    @State private var showConfirmation = false
    @State private var alertMessage = ""

    var body: some View {
        Button(action: {
            // Check first if already converted today
            let today = formattedToday()
            if lastScoreUploadDate == today {
                alertMessage = "You’ve already converted today’s score to coins."
                showAlert = true
            } else {
                showConfirmation = true
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "star.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.yellow)
                Text("\(scoreManager.totalScore)")
                    .font(.headline)
                    .padding(8)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .alert("Score Converted", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("Are you sure?", isPresented: $showConfirmation) {
            Button("Convert", role: .destructive) {
                pushScoreToFirestore()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to convert your score? This action can only be done once per day.")
        }
    }

    func pushScoreToFirestore() {
        guard !currentUserId.isEmpty else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }

        let today = formattedToday()

        if lastScoreUploadDate == today {
            alertMessage = "You’ve already converted today’s score to coins."
            showAlert = true
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserId)

        userRef.updateData([
            "score": FieldValue.increment(Int64(scoreManager.totalScore))
        ]) { error in
            if let error = error {
                alertMessage = "Failed to convert score: \(error.localizedDescription)"
            } else {
                lastScoreUploadDate = today
                alertMessage = "Score successfully converted to coins!"
            }
            showAlert = true
        }
    }

    func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView()
            .environmentObject(ScoreManager.shared)
    }
}

