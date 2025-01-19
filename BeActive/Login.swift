//
//  Login.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/1/2568 BE.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email: String = "" // เก็บอีเมล
    @State private var password: String = "" // เก็บรหัสผ่าน
    @State private var isPasswordVisible: Bool = false // เก็บสถานะการแสดงรหัสผ่าน
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 50)
                
                Text("Log In")
                    .padding(.top, 30)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("E-mail Address", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    ZStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password) // แสดงรหัสผ่าน
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            SecureField("Password", text: $password) // ซ่อนรหัสผ่าน
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                isPasswordVisible.toggle() // เปลี่ยนสถานะการแสดงรหัสผ่าน
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
                    Text("No account yet?")
                        .foregroundColor(.gray)
                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                            .foregroundColor(themeManager.textColor)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    // Add login action
                    print("E-mail: \(email), Password: \(password)")
                }) {
                    Text("Log In")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color(red: 90/255, green: 200/255, blue: 250/255))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .padding(.horizontal, 50)
                }
                .padding(.bottom, 450)
            }
            .background(themeManager.backgroundColor.ignoresSafeArea())
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .environmentObject(ThemeManager())
    }
}
