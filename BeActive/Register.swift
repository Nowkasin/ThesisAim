//
//  Register.swift
//  BeActive
//
//  Created by Kasin Thappawan on 10/1/2568 BE.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @StateObject var themeManager = ThemeManager()

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Title
                Text("Register")
                    .padding(.top, 30)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
                    .padding(.bottom, 20)

                // Form Fields
                Group {
                    CustomTextField(placeholder: "E-mail Address", textColor: themeManager.textColor, text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    CustomTextField(placeholder: "First Name", textColor: themeManager.textColor, text: $firstName)
                        .autocapitalization(.words)

                    CustomTextField(placeholder: "Last Name", textColor: themeManager.textColor, text: $lastName)
                        .autocapitalization(.words)

                    CustomTextField(placeholder: "Phone number", textColor: themeManager.textColor, text: $phoneNumber)
                        .keyboardType(.phonePad)

                    CustomSecureField(placeholder: "Password", textColor: themeManager.textColor, text: $password)
                }

                // Button
                Button(action: {
                    registerUser()
                }) {
                    Text("Sign Up")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color(red: 90/255, green: 200/255, blue: 250/255))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.top, 30)

                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }

    func registerUser() {
        guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            print("Please fill all fields.")
            return
        }
        print("User registered with email: \(email)")
    }
}

// Custom TextField Component
struct CustomTextField: View {
    var placeholder: String
    var textColor: Color
    @Binding var text: String

    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
                .foregroundColor(textColor) // ตั้งค่าสีข้อความที่ต้องการจาก themeManager
                .font(.system(size: 16)) // ใช้ฟอนต์ที่ต้องการ
                .padding(.vertical, 10)
                .padding(.horizontal, 5)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.5)),
                    alignment: .bottom
                )
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(textColor) // ใช้สี textColor สำหรับ placeholder
                }
        }
        .padding(.bottom, 15)
    }
}


// Custom SecureField Component
struct CustomSecureField: View {
    var placeholder: String
    var textColor: Color
    @Binding var text: String

    var body: some View {
        VStack {
            SecureField(placeholder, text: $text)
                .foregroundColor(textColor) // ตั้งค่าสีข้อความที่ต้องการจาก themeManager
                .font(.system(size: 16)) // ใช้ฟอนต์ที่ต้องการ
                .padding(.vertical, 10)
                .padding(.horizontal, 5)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.5)),
                    alignment: .bottom
                )
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(textColor) // ใช้สี textColor สำหรับ placeholder
                }
        }
        .padding(.bottom, 15)
    }
}


// Extension to make placeholder work
extension View {
    @ViewBuilder func placeholder<Content: View>(when shouldShow: Bool, @ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .leading) {
            self
            if shouldShow {
                content()
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

