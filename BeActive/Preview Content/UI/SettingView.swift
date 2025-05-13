//
//  SettingView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 26/1/2568 BE.
//

import SwiftUI

import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @Binding var isShowing: Bool
    @State private var showLanguageView = false
    @State private var showSleepScheduleView = false
    @ObservedObject var language = Language.shared
    @State private var showDeleteConfirmation = false

    @AppStorage("currentUserId") var currentUserId: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    let pdfURL = URL(string: "https://drive.google.com/drive/folders/1mvRi0p2DaLxE_LmAiD70kpMxLoWX1wLl?usp=sharing")!

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Title และปุ่มปิด
                HStack {
                    Text(t("Settings", in: "Setting_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 1)) {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                // ปุ่มเปลี่ยนภาษา
                settingButton(icon: "globe", title: t("Language", in: "Setting_screen")) {
                    withAnimation {
                        showLanguageView = true
                    }
                }

                // ปุ่มแจ้งเตือนน้ำ
                settingButton(icon: "bell", title: t("Water Notification", in: "Setting_screen")) {
                    withAnimation {
                        showSleepScheduleView = true
                    }
                }
                .fullScreenCover(isPresented: $showSleepScheduleView) {
                    SleepScheduleView()
                }

                // ปุ่มเปิดไฟล์ PDF
                Button(action: {
                    UIApplication.shared.open(pdfURL)
                }) {
                    HStack {
                        Image(systemName: "book")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text(t("How to use", in: "Setting_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal)
                }

                // Delete Account button
                settingButton(icon: "trash", title: t("Delete Account", in: "Setting_screen")) {
                    confirmDeleteAccount()
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text(t("Confirm Deletion", in: "Setting_screen")),
                        message: Text(t("Are you sure you want to permanently delete your account?", in: "Setting_screen")),
                        primaryButton: .destructive(Text(t("Delete", in: "Setting_screen"))) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel(Text(t("Cancel", in: "Setting_screen")))
                    )
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0)
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 1), value: isShowing)

            if showLanguageView {
                SwitchLang(isShowing: $showLanguageView)
            }
        }
    }

    // ปุ่ม Setting
    func settingButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
            )
            .padding(.horizontal)
        }
    }
    // MARK: - Delete Account helpers
    func confirmDeleteAccount() {
        showDeleteConfirmation = true
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let db = Firestore.firestore()

        // Step 1: Delete subcollection 'mates'
        let matesRef = db.collection("users").document(uid).collection("mates")
        matesRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch mates: \(error.localizedDescription)")
                return
            }

            let batch = db.batch()
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }

            batch.commit { batchError in
                if let batchError = batchError {
                    print("❌ Failed to delete mates: \(batchError.localizedDescription)")
                    return
                }

                // Step 2: Delete user document
                db.collection("users").document(uid).delete { userDocError in
                    if let userDocError = userDocError {
                        print("❌ Failed to delete user document: \(userDocError.localizedDescription)")
                        return
                    }

                    // Step 3: Delete Firebase Auth account
                    user.delete { authError in
                        if let authError = authError {
                            print("❌ Failed to delete auth account: \(authError.localizedDescription)")
                        } else {
                            print("✅ Fully deleted user account and all data")
                            // Optional: navigate to login screen
                            self.currentUserId = ""
                            self.isLoggedIn = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isShowingSettings = true
    return SettingsView(isShowing: $isShowingSettings)
        .preferredColorScheme(.dark)
}
