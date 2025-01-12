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
    @State private var errorMessage = ""
    @State private var isPasswordVisible = false
    @StateObject var themeManager = ThemeManager()

    private let passwordValidator = PasswordValidator()

    // เพิ่ม FocusState เพื่อควบคุมการ focus ของแต่ละช่องกรอกข้อมูล
    @FocusState private var focusedField: Field?

    enum Field {
        case email, firstName, lastName, phoneNumber, password
    }

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
                        .focused($focusedField, equals: .email)

                    CustomTextField(placeholder: "First Name", textColor: themeManager.textColor, text: $firstName)
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .firstName)

                    CustomTextField(placeholder: "Last Name", textColor: themeManager.textColor, text: $lastName)
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .lastName)

                    CustomTextField(placeholder: "Phone number", textColor: themeManager.textColor, text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phoneNumber)

                    CustomPasswordField(placeholder: "Password", textColor: themeManager.textColor, text: $password, isPasswordVisible: $isPasswordVisible)
                        .focused($focusedField, equals: .password)
                        .onChange(of: password) { newValue in
                            validatePassword(newValue)
                        }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
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

                Spacer() // ระยะห่างด้านล่าง
            }
            .padding(.horizontal, 30)
        }
    }

    func registerUser() {
        guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }

        if passwordValidator.validatePassword(password) {
            print("User registered with email: \(email)")
            errorMessage = ""
        } else {
            errorMessage = passwordValidator.errorMessage
        }
    }

    private func validatePassword(_ password: String) {
        if !passwordValidator.validatePassword(password) {
            errorMessage = passwordValidator.errorMessage
        } else {
            errorMessage = ""
        }
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
                .foregroundColor(textColor)
                .font(.system(size: 16))
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
                        .foregroundColor(textColor.opacity(0.6))
                }
        }
        .padding(.bottom, 15)
    }
}

// Custom PasswordField Component
struct CustomPasswordField: View {
    var placeholder: String
    var textColor: Color
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    var body: some View {
        VStack {
            HStack {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                        .foregroundColor(textColor)
                        .font(.system(size: 16))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 5)
                } else {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(textColor)
                        .font(.system(size: 16))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 5)
                }

                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.5)),
                alignment: .bottom
            )
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(textColor.opacity(0.6))
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
