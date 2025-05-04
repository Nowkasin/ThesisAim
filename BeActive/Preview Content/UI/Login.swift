//
//  Login.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/1/2568 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import CryptoKit
import Kingfisher

struct SplashScreen: View {
    @Binding var isActive: Bool
    let imageUrl: URL
    @State private var isFadedIn: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            KFImage(imageUrl)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .opacity(isFadedIn ? 1 : 0)
                .scaleEffect(isActive ? 2 : 1)
                .animation(.easeInOut(duration: 3), value: isActive)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        isFadedIn = true
                    }
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    isActive = true
                }
            }
        }
    }
}

struct Login: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @ObservedObject var language = Language.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSplashScreenActive: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showRegisterScreen = false
    @State private var isLoading = false
    @State private var bounce = false
    @State private var showPassword: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if isSplashScreenActive {
                    if isLoggedIn {
                        MainTab()
                    } else {
                        loginForm
                    }
                } else {
                    SplashScreen(
                        isActive: $isSplashScreenActive,
                        imageUrl: URL(string: "https://i.imgur.com/e1w6vHJ.png")!
                    )
                    .transition(.opacity)
                }
            }
        }
    }

    var loginForm: some View {
        ZStack {
            VStack(alignment: .leading) {
                Spacer().frame(height: 60)
                
                Text(t("log_in", in: "login_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 36))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    TextField(t("e_mail", in: "login_screen"), text: $email)
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                        .padding(.bottom, 10)
                        .foregroundColor(.primary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                VStack(alignment: .leading) {
                    ZStack(alignment: .trailing) {
                        Group {
                            if showPassword {
                                TextField(t("password", in: "login_screen"), text: $password)
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                            } else {
                                SecureField(t("password", in: "login_screen"), text: $password)
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                            }
                        }
                        .padding(.bottom, 10)

                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                            .onLongPressGesture(minimumDuration: 0.01, pressing: { isPressing in
                                withAnimation {
                                    showPassword = isPressing
                                }
                            }, perform: {})
                    }

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal, 20)

                
                HStack {
                    Spacer()
                    Text(t("no_account_yet", in: "login_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 13))
                        .foregroundColor(.secondary)
                    Button(action: {
                        showRegisterScreen = true
                    }) {
                        Text(t("register", in: "login_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 13))
                    }
                    .foregroundColor(.blue)
                    .fullScreenCover(isPresented: $showRegisterScreen) {
                        RegisterView()
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: handleLogin) {
                    Text(t("log_in", in: "login_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(35)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .hideKeyboardOnTap()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(t("Login Failed", in: "login_screen")),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(t("ok", in: "login_screen")))
                )
            }
            
            // ✅ Overlay โหลด
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)

                    Text(t("logging_in", in: "login_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                        .offset(y: bounce ? -10 : 10) // ขยับขึ้นลง
                        .animation(
                            Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                            value: bounce
                        )
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .onAppear {
                    bounce = true
                }
                .onDisappear {
                    bounce = false
                }
            }
        }
    }

    func handleLogin() {
        isLoading = true
        let db = Firestore.firestore()
        let hashedInput = hashPassword(password)

        db.collection("users").getDocuments { snapshot, error in
            isLoading = false
            if let error = error {
                alertMessage = t("Error fetching users", in: "login_screen")
                showAlert = true
                return
            }

            guard let documents = snapshot?.documents else {
                alertMessage = t("No users found", in: "login_screen")
                showAlert = true
                return
            }

            for document in documents {
                let data = document.data()
                let storedEmail = data["email"] as? String ?? ""
                let storedHashedPass = data["pass"] as? String ?? ""

                if storedEmail.lowercased() == email.lowercased() && storedHashedPass == hashedInput {
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            alertMessage = t("Authentication failed", in: "login_screen")
                            showAlert = true
                            return
                        }

                        guard let user = authResult?.user else {
                            alertMessage = t("User authentication failed", in: "login_screen")
                            showAlert = true
                            return
                        }

                        user.reload { reloadError in
                            if let reloadError = reloadError {
                                alertMessage = t("Failed to reload user info", in: "login_screen")
                                showAlert = true
                                return
                            }

                            if user.isEmailVerified {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation {
                                        isLoggedIn = true
                                        currentUserId = document.documentID
                                    }
                                }
                            } else {
                                alertMessage = t("Please verify your email before logging in", in: "login_screen")
                                showAlert = true
                                try? Auth.auth().signOut()
                            }
                        }
                    }
                    return
                }
            }

            alertMessage = t("Incorrect Email or Password.", in: "login_screen")
            showAlert = true
        }
    }

    func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager.shared)
    }
}
