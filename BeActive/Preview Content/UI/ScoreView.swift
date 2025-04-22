//
//  ScoreView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 24/2/2568 BE.
//

import SwiftUI
import FirebaseFirestore

struct ScoreView: View {
    @ObservedObject var language = Language.shared
    @EnvironmentObject var scoreManager: ScoreManager
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("lastScoreUploadDate") private var lastScoreUploadDate: String = ""

    @State private var showAlert = false
    @State private var showConfirmation = false
    @State private var alertMessage = ""

    var body: some View {
        Button(action: {
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
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                    .padding(8)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.trailing, 10)
        }
        .alert(t("Score Converted", in: "Noti_Screen.SC"), isPresented: $showAlert) {
            Button(t("OK", in: "Noti_Screen.SC"), role: .cancel) {}
        } message: {
            Text(t(alertMessage, in: "Noti_Screen.SC"))
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
        }
        .alert(t("Are you sure?", in: "Noti_Screen.SC"), isPresented: $showConfirmation) {
            Button(t("Convert", in: "Noti_Screen.SC"), role: .destructive) {
                pushScoreToFirestore()
            }
            Button(t("Cancel", in: "Noti_Screen.SC"), role: .cancel) {}
        } message: {
            Text(t("Are you sure you want to convert your score? This action can only be done once per day.", in: "Noti_Screen.SC"))
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
        }
        .onAppear {
            scoreManager.resetTotalScoreIfNewDay()
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
