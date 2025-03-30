//
//  Login.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/1/2568 BE.
//

//import SwiftUI
//
//struct Login: View {
//    @EnvironmentObject var themeManager: ThemeManager
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isPasswordVisible: Bool = false
//    @State private var isLoggedIn: Bool = false
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                if isLoggedIn {
//                    HomeView()
//                        .transition(.move(edge: .trailing))
//                        .animation(.easeInOut(duration: 0.5), value: isLoggedIn)
//                } else {
//                    VStack {
//                        Spacer().frame(height: 50)
//
//                        // ใช้ฟังก์ชัน t() สำหรับการแปล
//                        Text(t("log_in", in: "login_screen"))
//                            .padding(.top, 30)
//                            .font(.system(size: 32, weight: .bold))
//                            .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
//                            .padding(.bottom, 20)
//
//                        VStack(alignment: .leading, spacing: 15) {
//                            TextField(t("e_mail", in: "login_screen"), text: $email)
//                                .padding()
//                                .background(Color(.systemGray6))
//                                .cornerRadius(8)
//                                .autocapitalization(.none)
//                                .keyboardType(.emailAddress)
//
//                            ZStack {
//                                if isPasswordVisible {
//                                    TextField(t("password", in: "login_screen"), text: $password)
//                                        .padding()
//                                        .background(Color(.systemGray6))
//                                        .cornerRadius(8)
//                                } else {
//                                    SecureField(t("password", in: "login_screen"), text: $password)
//                                        .padding()
//                                        .background(Color(.systemGray6))
//                                        .cornerRadius(8)
//                                }
//
//                                HStack {
//                                    Spacer()
//                                    Button(action: {
//                                        isPasswordVisible.toggle()
//                                    }) {
//                                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
//                                            .foregroundColor(.gray)
//                                    }
//                                    .padding(.trailing, 10)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//
//                        HStack {
//                            Spacer()
//                            Text(t("no_account_yet", in: "login_screen"))
//                                .foregroundColor(.gray)
//                            NavigationLink(destination: RegisterView()) {
//                                Text(t("register", in: "login_screen"))
//                                    .foregroundColor(themeManager.textColor)
//                            }
//                        }
//                        .padding(.top, 10)
//                        .padding(.horizontal, 20)
//
//                        Spacer()
//
//                        Button(action: {
//                            withAnimation {
//                                isLoggedIn = true
//                            }
//                        }) {
//                            Text(t("log_in", in: "login_screen"))
//                                .font(.system(size: 18, weight: .medium))
//                                .frame(maxWidth: .infinity, minHeight: 50)
//                                .background(Color(red: 90/255, green: 200/255, blue: 250/255))
//                                .foregroundColor(.white)
//                                .cornerRadius(25)
//                                .padding(.horizontal, 50)
//                        }
//                        .padding(.bottom, 50)
//                    }
//                    .background(themeManager.backgroundColor.ignoresSafeArea())
//                }
//            }
//        }
//    }
//}
//
//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//        Login()
//            .environmentObject(ThemeManager())
//            .environmentObject(HealthManager())
//    }
//}

import SwiftUI

struct SplashScreen: View {
    @Binding var isActive: Bool
    let imageUrl: URL
    @State private var isFadedIn: Bool = false
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView() // Show a loading indicator
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .opacity(isFadedIn ? 1 : 0) // Fade-in animation
                        .scaleEffect(isActive ? 2 : 1)
                        .animation(.easeInOut(duration: 3), value: isActive)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                isFadedIn = true // Start fade-in animation
                            }
                        }
                case .failure:
                    Image(systemName: "xmark.octagon") // Fallback in case of failure
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
            // Simulate a delay for the splash screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    isActive = true // Start fading out and move to login
                }
            }
        }
    }
}

struct Login: View {
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // ✅ ใช้ AppStorage เพื่อให้แอปรู้สถานะล็อกอิน
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isSplashScreenActive: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if isSplashScreenActive {
                    if isLoggedIn {
                        MainTab() // ✅ เปลี่ยนไป `MainTab()` หลังจากล็อกอิน
                            .transition(.move(edge: .trailing))
                            .animation(.easeInOut(duration: 0.5), value: isLoggedIn)
                    } else {
                        VStack {
                            Spacer().frame(height: 50)

                            Text(t("log_in", in: "login_screen"))
                                .padding(.top, 30)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
                                .padding(.bottom, 20)

                            VStack(alignment: .leading, spacing: 15) {
                                TextField(t("e_mail", in: "login_screen"), text: $email)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)

                                ZStack {
                                    if isPasswordVisible {
                                        TextField(t("password", in: "login_screen"), text: $password)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    } else {
                                        SecureField(t("password", in: "login_screen"), text: $password)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }

                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)

                            HStack {
                                Spacer()
                                Text(t("no_account_yet", in: "login_screen"))
                                    .foregroundColor(.gray)
                                NavigationLink(destination: RegisterView()) {
                                    Text(t("register", in: "login_screen"))
                                        .foregroundColor(themeManager.textColor)
                                }
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 20)

                            Spacer()

                            Button(action: {
                                handleLogin() // ✅ เปลี่ยนไป MainTab เมื่อกดปุ่ม
                            }) {
                                Text(t("log_in", in: "login_screen"))
                                    .font(.system(size: 18, weight: .medium))
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color(red: 90/255, green: 200/255, blue: 250/255))
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                                    .padding(.horizontal, 50)
                            }
                            .padding(.bottom, 50)
                        }
                        .background(themeManager.backgroundColor.ignoresSafeArea())
                    }
                } else {
                    SplashScreen(
                        isActive: $isSplashScreenActive,
                        imageUrl: URL(string: "https://i.pinimg.com/736x/82/02/61/820261b353a82247509001ad71b18899.jpg")!
                    )
                        .transition(.opacity)
                }
            }
        }
    }

    /// ✅ ฟังก์ชันจำลองการล็อกอิน
    func handleLogin() {
        withAnimation {
            isLoggedIn = true // ✅ อัปเดตสถานะล็อกอิน → ไปหน้า `MainTab`
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .environmentObject(ThemeManager())
            .environmentObject(HealthManager())
            .environmentObject(ScoreManager())
    }
}
