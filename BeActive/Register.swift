//
//  Register.swift
//  BeActive
//
//  Created by Kasin Thappawan on 10/1/2568 BE.
//
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isPasswordVisible = false
    private let passwordValidator = PasswordValidator()

    @FocusState private var focusedField: Field?

    enum Field {
        case email, firstName, lastName, phoneNumber, password
    }

    var body: some View {
        
        ZStack {
            themeManager.backgroundColor
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text(t("register", in: "register_screen"))
                 // ใช้ฟังก์ชัน t() สำหรับข้อความ
                    .padding(.top, 30)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
                    .padding(.bottom, 20)

                Group {
                    CustomTextField(placeholder:
                                        (t("e_mail", in: "register_screen")), text: $email) // ใช้ t() แปล
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)

                    CustomTextField(placeholder:
                                        (t("first_name", in: "register_screen"))
                                        , text: $firstName) // ใช้ t() แปล
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .firstName)

                    CustomTextField(placeholder:
                                        (t("last_name", in: "register_screen")), text: $lastName) // ใช้ t() แปล
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .lastName)

                    CustomTextField(placeholder:
                                        (t("phone_number", in: "register_screen")), text: $phoneNumber) // ใช้ t() แปล
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .phoneNumber)

                    CustomPasswordField(placeholder:
                                            (t("password", in: "register_screen")), text: $password, isPasswordVisible: $isPasswordVisible) // ใช้ t() แปล
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

                Button(action: {
                    registerUser()
                }) {
                    Text(t("sign_up", in: "register_screen")) // ใช้ t() แปล
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
            errorMessage = (t("fill_all_fields", in: "register_screen")) // ใช้ t() แปล
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
    var backgroundColor: Color = Color(.systemGray6) // เพิ่มตัวเลือกสำหรับสีพื้นหลัง
    @Binding var text: String

    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding()
                .background(backgroundColor) // ใช้สีพื้นหลังที่กำหนด
                .cornerRadius(8) // เพิ่มมุมโค้งมน
        }
        .padding(.bottom, 15)
    }
}


// Custom PasswordField Component
struct CustomPasswordField: View {
    var placeholder: String
    var backgroundColor: Color = Color(.systemGray6) // เพิ่มสีพื้นหลัง
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    var body: some View {
        VStack {
            HStack {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .padding()
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .padding()
                }

                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
            }
            .background(backgroundColor) // ใช้สีพื้นหลังที่กำหนด
            .cornerRadius(8) // เพิ่มมุมโค้งมน
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
            .environmentObject(ThemeManager()) // Pass the ThemeManager environment object to the view
//            .environmentObject(HealthManager())
    }
}

