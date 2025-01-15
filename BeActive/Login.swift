//
//  Login.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/1/2568 BE.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView { // เพิ่ม NavigationView เพื่อใช้ NavigationLink
            VStack {
                Spacer().frame(height: 50)
                
                Text("Log In")
                    .padding(.top, 30)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("E-mail Address", text: .constant(""))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: .constant(""))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Spacer()
                    Text("No account yet?")
                        .foregroundColor(.gray)
                    NavigationLink(destination: RegisterView()) { // ใช้ NavigationLink เพื่อเปลี่ยนหน้า
                        Text("Register")
                            .foregroundColor(themeManager.textColor) // ใช้สีข้อความจาก ThemeManager
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    // Add login action
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
            .background(themeManager.backgroundColor.ignoresSafeArea()) // ใช้สีพื้นหลังจาก ThemeManager
        }
    }
}


struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .environmentObject(ThemeManager()) // Pass the ThemeManager environment object to the view
    }
}
