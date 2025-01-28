//
//  Login.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/1/2568 BE.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoggedIn {
                    HomeView()
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut(duration: 0.5), value: isLoggedIn)
                } else {
                    VStack {
                        Spacer().frame(height: 50)

                        // ใช้ฟังก์ชัน t() สำหรับการแปล
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
                            withAnimation {
                                isLoggedIn = true
                            }
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
            }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .environmentObject(ThemeManager())
            .environmentObject(HealthManager())
    }
}
