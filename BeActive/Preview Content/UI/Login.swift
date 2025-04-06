//
//  Login.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/1/2568 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import CryptoKit

struct SplashScreen: View {
    @Binding var isActive: Bool
    let imageUrl: URL
    @State private var isFadedIn: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
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
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .foregroundColor(.red)
                        .opacity(isFadedIn ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                isFadedIn = true
                            }
                        }
                @unknown default:
                    EmptyView()
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

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSplashScreenActive: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showRegisterScreen = false

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
                        imageUrl: URL(string: "https://i.imgur.com/TR7HwEa.png")!
                    )
                    .transition(.opacity)
                }
            }
        }
    }

    var loginForm: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 60)

            Text("Log In")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading, 20)
                .padding(.bottom, 40)

            VStack(alignment: .leading) {
                TextField("E-mail Address", text: $email)
                    .padding(.bottom, 10)
                    .foregroundColor(.primary)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            VStack(alignment: .leading) {
                SecureField("Password", text: $password)
                    .padding(.bottom, 10)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 20)

            HStack {
                Spacer()
                Text("No account yet?")
                    .foregroundColor(.secondary)
                Button("Register") {
                    showRegisterScreen = true
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
                Text("Log In")
                    .font(.system(size: 18, weight: .medium))
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
            Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func handleLogin() {
        let db = Firestore.firestore()
        let hashedInput = hashPassword(password)

        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                alertMessage = "Error fetching users: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let documents = snapshot?.documents else {
                alertMessage = "No users found."
                showAlert = true
                return
            }

            for document in documents {
                let data = document.data()
                let storedEmail = data["email"] as? String ?? ""
                let storedHashedPass = data["pass"] as? String ?? ""

                if storedEmail.lowercased() == email.lowercased() && storedHashedPass == hashedInput {
                    withAnimation {
                        isLoggedIn = true
                        currentUserId = document.documentID
                    }
                    return
                }
            }

            alertMessage = "Incorrect Email or Password."
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



