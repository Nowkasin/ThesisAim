//
//  Register.swift
//  BeActive
//
//  Created by Kasin Thappawan on 10/1/2568 BE.
//

//import SwiftUI
//import Firebase
//import FirebaseFirestore
//
//struct RegisterView: View {
//    @EnvironmentObject var themeManager: ThemeManager
//
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var age = ""
//    @State private var sex = ""
//    @State private var height = ""
//    @State private var weight = ""
//    @State private var phoneNumber = ""
//
//    @State private var errorMessage = ""
//    @State private var isPasswordVisible = false
//    @State private var showSuccessAlert = false
//    @State private var showLoginScreen = false
//
//    private let passwordValidator = PasswordValidator()
//    let sexOptions = ["Male", "Female", "Other"]
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
////                themeManager.backgroundColor
////                    .ignoresSafeArea()
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 0) {
//                        Text("Register")
//                            .font(.system(size: 32, weight: .bold))
//                            .foregroundColor(Color(red: 60/255, green: 60/255, blue: 90/255))
//                            .padding(.top, 40)
//                            .padding(.bottom, 30)
//
//                        Group {
//                            CustomTextField(placeholder: "Full Name", text: $name)
//                            CustomTextField(placeholder: "E-mail Address", text: $email)
//                            CustomPasswordField(placeholder: "Password", text: $password, isPasswordVisible: $isPasswordVisible)
//                                .onChange(of: password) { newValue in
//                                    validatePassword(newValue)
//                                }
//                            CustomTextField(placeholder: "Age", text: $age)
//                            SexPickerView(sex: $sex, sexOptions: sexOptions)
//                            CustomTextField(placeholder: "Height (cm)", text: $height)
//                            CustomTextField(placeholder: "Weight (kg)", text: $weight)
//                            CustomTextField(placeholder: "Phone", text: $phoneNumber)
//                        }
//
//                        if !errorMessage.isEmpty {
//                            Text(errorMessage)
//                                .foregroundColor(.red)
//                                .font(.caption)
//                                .padding(.top, 5)
//                        }
//
//                        Button(action: {
//                            registerUser()
//                        }) {
//                            Text("Sign Up")
//                                .font(.system(size: 18, weight: .medium))
//                                .frame(maxWidth: .infinity, minHeight: 50)
//                                .background(Color(red: 90/255, green: 200/255, blue: 250/255))
//                                .foregroundColor(.white)
//                                .cornerRadius(25)
//                        }
//                        .padding(.top, 30)
//                        .padding(.bottom, 40)
//
//                        HStack {
//                            Text("Already have an account?")
//                                .foregroundColor(.primary)
//                            Button("Log In") {
//                                showLoginScreen = true
//                            }
//                            .foregroundColor(.blue)
//                        }
//                        .font(.footnote)
//                        .frame(maxWidth: .infinity)
//                    }
//                    .padding(.horizontal, 30)
//                }
//                .ignoresSafeArea(.keyboard)
//                .dismissKeyboardOnTap()
//            }
//            .alert("Registration Successful", isPresented: $showSuccessAlert) {
//                Button("OK") {
//                    showLoginScreen = true
//                }
//            } message: {
//                Text("You have successfully registered.")
//            }
//            .fullScreenCover(isPresented: $showLoginScreen) {
//                Login()
//            }
//        }
//    }
//
//    func registerUser() {
//        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !age.isEmpty,
//              !height.isEmpty, !weight.isEmpty, !phoneNumber.isEmpty, !sex.isEmpty else {
//            errorMessage = "Please fill in all fields."
//            return
//        }
//
//        guard let ageNum = Int(age), let heightNum = Int(height), let weightNum = Int(weight) else {
//            errorMessage = "Age, height, and weight must be valid numbers."
//            return
//        }
//
//        guard phoneNumber.count == 10, phoneNumber.allSatisfy({ $0.isNumber }) else {
//            errorMessage = "Phone number must be exactly 10 digits."
//            return
//        }
//
//        guard passwordValidator.validatePassword(password) else {
//            errorMessage = passwordValidator.errorMessage
//            return
//        }
//
//        let db = Firestore.firestore()
//        let userData: [String: Any] = [
//            "name": name,
//            "email": email,
//            "pass": password,
//            "age": ageNum,
//            "sex": sex,
//            "height": heightNum,
//            "weight": weightNum,
//            "phone": phoneNumber
//        ]
//
//        db.collection("users").addDocument(data: userData) { error in
//            if let error = error {
//                errorMessage = "Failed to register: \(error.localizedDescription)"
//            } else {
//                errorMessage = ""
//                showSuccessAlert = true
//            }
//        }
//    }
//
//    private func validatePassword(_ password: String) {
//        if !passwordValidator.validatePassword(password) {
//            errorMessage = passwordValidator.errorMessage
//        } else {
//            errorMessage = ""
//        }
//    }
//}
//
//// MARK: - Minimal Text Field
//struct CustomTextField: View {
//    var placeholder: String
//    @Binding var text: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            TextField(placeholder, text: $text)
//                .font(.system(size: 16))
//                .padding(.vertical, 10)
//                .foregroundColor(.primary)
//
//            Divider()
//                .background(Color.gray.opacity(0.4))
//        }
//        .padding(.bottom, 15)
//    }
//}
//
//// MARK: - Minimal Password Field
//struct CustomPasswordField: View {
//    var placeholder: String
//    @Binding var text: String
//    @Binding var isPasswordVisible: Bool
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                if isPasswordVisible {
//                    TextField(placeholder, text: $text)
//                } else {
//                    SecureField(placeholder, text: $text)
//                }
//
//                Button(action: {
//                    isPasswordVisible.toggle()
//                }) {
//                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
//                        .foregroundColor(.gray)
//                }
//            }
//            .font(.system(size: 16))
//            .padding(.vertical, 10)
//
//            Divider()
//                .background(Color.gray.opacity(0.4))
//        }
//        .padding(.bottom, 15)
//    }
//}
//
//// MARK: - Sex Picker (Styled)
//struct SexPickerView: View {
//    @Binding var sex: String
//    let sexOptions: [String]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("Sex")
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//
//            Menu {
//                ForEach(sexOptions, id: \.self) { option in
//                    Button(action: {
//                        sex = option
//                    }) {
//                        Text(option)
//                    }
//                }
//            } label: {
//                HStack {
//                    Text(sex.isEmpty ? "Select" : sex)
//                        .foregroundColor(sex.isEmpty ? .gray : .primary)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                        .foregroundColor(.gray)
//                }
//                .padding(.vertical, 10)
//            }
//
//            Divider()
//                .background(Color.gray.opacity(0.4))
//        }
//        .padding(.bottom, 15)
//    }
//}
//
//// MARK: - Dismiss Keyboard
//extension View {
//    func dismissKeyboardOnTap() -> some View {
//        modifier(DismissKeyboardOnTap())
//    }
//}
//
//struct DismissKeyboardOnTap: ViewModifier {
//    func body(content: Content) -> some View {
//        content.gesture(
//            TapGesture().onEnded {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }
//        )
//    }
//}
//
//// MARK: - Preview
//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView()
//            .environmentObject(ThemeManager())
//    }
//}

import SwiftUI
import Firebase
import FirebaseFirestore
import CryptoKit

struct RegisterView: View {
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
    @State private var isPressed = false
    @State private var appear = false

    private let passwordValidator = PasswordValidator()
    let sexOptions = [
        t("Male", in: "register_screen"),
        t("Female", in: "register_screen"),
        t("Other", in: "register_screen")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(t("register", in: "register_screen"))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.top, 40)
                            .padding(.bottom, 30)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                            .animation(.easeOut(duration: 0.6), value: appear)

                        
                        Group {
                            CustomTextField(placeholder: t("first_name", in: "register_screen"), text: $name)
                            CustomTextField(placeholder: t("e_mail", in: "register_screen"), text: $email)
                            CustomPasswordField(placeholder: t("password", in: "register_screen"), text: $password, isPasswordVisible: $isPasswordVisible)
                                .onChange(of: password) { newValue in
                                    validatePassword(newValue)
                                }
                            CustomTextField(placeholder: t("Age", in: "register_screen"), text: $age)
                            SexPickerView(sex: $sex, sexOptions: sexOptions)
                            CustomTextField(placeholder: t("Height (cm)", in: "register_screen"), text: $height)
                            CustomTextField(placeholder: t("Weight (kg)", in: "register_screen"), text: $weight)
                            CustomTextField(placeholder: t("phone_number", in: "register_screen"), text: $phoneNumber)
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
                            Text(t("sign_up", in: "register_screen"))
                                .font(.system(size: 18, weight: .medium))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .scaleEffect(isPressed ? 0.96 : 1.0)
                                .animation(.spring(), value: isPressed)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isPressed = true }
                                .onEnded { _ in isPressed = false }
                        )
                        .padding(.top, 30)
                        .padding(.bottom, 40)
                        
                        HStack {
                            Text(t("have a member?", in: "register_screen"))
                                .foregroundColor(.primary)
                            Button(t("log_in", in: "login_screen")) {
                                showLoginScreen = true
                            }
                            .foregroundColor(.blue)
                        }
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 30)
                }
                .onAppear {
                    appear = true
                }
                .ignoresSafeArea(.keyboard)
                .dismissKeyboardOnTap()
            }
            .background(Color(.systemBackground))
            .alert(t("register", in: "register_screen"), isPresented: $showSuccessAlert) {
                Button("OK") {
                    withAnimation {
                        showLoginScreen = true
                    }
                }
            } message: {
                Text("You have successfully registered.")
            }
            .fullScreenCover(isPresented: $showLoginScreen) {
                Login()
            }
        }
    }
    
    func registerUser() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !age.isEmpty,
              !height.isEmpty, !weight.isEmpty, !phoneNumber.isEmpty, !sex.isEmpty else {
            errorMessage = t("fill_all_fields", in: "register_screen")
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
        
        let hashedPassword = hashPassword(password)
        
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "pass": hashedPassword,
            "age": ageNum,
            "sex": sex,
            "height": heightNum,
            "weight": weightNum,
            "phone": phoneNumber,
            "score": 0
        ]
        
        var newUserRef: DocumentReference? = nil
        newUserRef = db.collection("users").addDocument(data: userData) { error in
            if let error = error {
                errorMessage = "Failed to register: \(error.localizedDescription)"
            } else if let userRef = newUserRef {
                userRef.collection("mates").document("Bear").setData([
                    "unlocked": true
                ]) { mateError in
                    if let mateError = mateError {
                        print("⚠️ Failed to unlock Bear: \(mateError.localizedDescription)")
                    }
                }
                
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
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}


// MARK: - Minimal Text Field
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(.vertical, 10)
                .foregroundColor(.primary)
            
            Divider()
                .background(Color.gray.opacity(0.4))
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Minimal Password Field
struct CustomPasswordField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
            }
            .font(.system(size: 16))
            .padding(.vertical, 10)
            
            Divider()
                .background(Color.gray.opacity(0.4))
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Sex Picker (Styled)
struct SexPickerView: View {
    @Binding var sex: String
    let sexOptions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Sex", in: "register_screen"))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
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
                    Text(sex.isEmpty ? t("Select", in: "register_screen") : sex)
                        .foregroundColor(sex.isEmpty ? .gray : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
            }
            
            Divider()
                .background(Color.gray.opacity(0.4))
        }
        .padding(.bottom, 15)
    }
}

// MARK: - Dismiss Keyboard
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
        Group {
            RegisterView().preferredColorScheme(.light)
            RegisterView().preferredColorScheme(.dark)
        }
    }
}
