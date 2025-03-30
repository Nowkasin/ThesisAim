//
//  Register.swift
//  BeActive
//
//  Created by Kasin Thappawan on 10/1/2568 BE.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// แปลภาษาด้วย

struct RegisterView: View {
    @EnvironmentObject var themeManager: ThemeManager

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var age = ""
    @State private var sex = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var phoneNumber = ""

    @State private var errorMessage = ""
    @State private var isPasswordVisible = false
    @State private var showSuccessAlert = false
    @State private var showLoginScreen = false

    private let passwordValidator = PasswordValidator()

    let sexOptions = ["Male", "Female", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        Text("Register")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 135/255, green: 206/255, blue: 235/255))
                            .padding(.top, 30)
                            .padding(.bottom, 20)

                        Group {
                            CustomTextField(placeholder: "Full Name", text: $name)
                                .autocapitalization(.words)

                            CustomTextField(placeholder: "Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            CustomPasswordField(placeholder: "Password", text: $password, isPasswordVisible: $isPasswordVisible)
                                .onChange(of: password) { newValue in
                                    validatePassword(newValue)
                                }

                            CustomTextField(placeholder: "Age", text: $age)
                                .keyboardType(.numberPad)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Sex")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Menu {
                                    ForEach(sexOptions, id: \.self) { option in
                                        Button(action: {
                                            sex = option
                                        }) {
                                            Text(option)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(sex.isEmpty ? "Select" : sex)
                                            .foregroundColor(sex.isEmpty ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.bottom, 15)

                            CustomTextField(placeholder: "Height (cm)", text: $height)
                                .keyboardType(.numberPad)

                            CustomTextField(placeholder: "Weight (kg)", text: $weight)
                                .keyboardType(.numberPad)

                            CustomTextField(placeholder: "Phone", text: $phoneNumber)
                                .keyboardType(.numberPad)
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }

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
                        .padding(.bottom, 50)
                    }
                    .padding(.horizontal, 30)
                }
                .ignoresSafeArea(.keyboard)
                .dismissKeyboardOnTap()
            }
            .alert("Registration Successful", isPresented: $showSuccessAlert) {
                Button("OK") {
                    showLoginScreen = true
                }
            } message: {
                Text("You have successfully registered.")
            }
            .fullScreenCover(isPresented: $showLoginScreen) {
                Login() // ⬅️ Replace with your actual login screen
            }
        }
    }

    func registerUser() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !age.isEmpty,
              !height.isEmpty, !weight.isEmpty, !phoneNumber.isEmpty, !sex.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard let ageNum = Int(age), let heightNum = Int(height), let weightNum = Int(weight) else {
            errorMessage = "Age, height, and weight must be valid numbers."
            return
        }

        guard phoneNumber.count == 10, phoneNumber.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Phone number must be exactly 10 digits."
            return
        }

        guard passwordValidator.validatePassword(password) else {
            errorMessage = passwordValidator.errorMessage
            return
        }

        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "pass": password,
            "age": ageNum,
            "sex": sex,
            "height": heightNum,
            "weight": weightNum,
            "phone": phoneNumber
        ]

        db.collection("users").addDocument(data: userData) { error in
            if let error = error {
                errorMessage = "Failed to register: \(error.localizedDescription)"
            } else {
                errorMessage = ""
                showSuccessAlert = true
            }
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

// MARK: - Custom TextField
struct CustomTextField: View {
    var placeholder: String
    var backgroundColor: Color = Color(.systemGray6)
    @Binding var text: String

    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Custom PasswordField
struct CustomPasswordField: View {
    var placeholder: String
    var backgroundColor: Color = Color(.systemGray6)
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
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .padding(.bottom, 15)
    }
}

// MARK: - View Extension to Dismiss Keyboard
extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.gesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(ThemeManager())
    }
}

