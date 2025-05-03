//
//  Register.swift
//  BeActive
//
//  Created by Kasin Thappawan on 10/1/2568 BE.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

struct RegisterView: View {
    @ObservedObject var language = Language.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var age = ""
    @State private var sex = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var phoneNumber = ""
    @State private var job = ""
    
    @State private var errorMessage = ""
    @State private var isPasswordVisible = false
    @State private var showSuccessAlert = false
    @State private var showLoginScreen = false
    @State private var isPressed = false
    @State private var appear = false

    private let passwordValidator = PasswordValidator()
    let sexOptions = ["Male", "Female", "Other"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(t("register", in: "register_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 32))
                            .foregroundColor(.primary)
                            .padding(.top, 40)
                            .padding(.bottom, 30)
//                            .opacity(appear ? 1 : 0)
//                            .offset(y: appear ? 0 : 20)
//                            .animation(.easeOut(duration: 0.6), value: appear)

                        
                        Group {
                            CustomTextField(placeholder: t("first_name", in: "register_screen"), text: $name, language: language)
                            CustomTextField(placeholder: t("e_mail", in: "register_screen"), text: $email, language: language)
                            CustomPasswordField(placeholder: t("password", in: "register_screen"), text: $password, isPasswordVisible: $isPasswordVisible, language: language)
                                .onChange(of: password) { newValue in
                                    validatePassword(newValue)
                                }
                            CustomTextField(placeholder: t("Age", in: "register_screen"), text: $age, language: language, keyboardType: .numberPad)
                            SexPickerView(sex: $sex, sexOptions: sexOptions, language: language)
                            JobPickerView(job: $job, jobOptions: ["Student / University", "Office Worker", "Freelancer", "Self-Employed", "Jobless"], language: language)
                            CustomTextField(placeholder: t("Height (cm)", in: "register_screen"), text: $height, language: language, keyboardType: .numberPad)
                            CustomTextField(placeholder: t("Weight (kg)", in: "register_screen"), text: $weight, language: language, keyboardType: .numberPad)
                            CustomTextField(placeholder: t("phone_number", in: "register_screen"), text: $phoneNumber, language: language, keyboardType: .numberPad)
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
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
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
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 13))
                            Button(t("log_in", in: "login_screen")) {
                                showLoginScreen = true
                            }
                            .foregroundColor(.blue)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 13))
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
                Text(t("register_success", in: "register_screen"))
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
        
        guard !job.isEmpty else {
            errorMessage = t("fill_all_fields", in: "register_screen")
            return
        }

        guard let ageNum = Int(age), ageNum >= 0, ageNum <= 999 else {
            errorMessage = t("invalid_age", in: "register_screen")
            return
        }

        guard let heightNum = Int(height), heightNum >= 10, heightNum <= 999 else {
            errorMessage = t("invalid_height", in: "register_screen")
            return
        }

        guard let weightNum = Int(weight), weightNum >= 10, weightNum <= 999 else {
            errorMessage = t("invalid_weight", in: "register_screen")
            return
        }

        guard phoneNumber.count == 10, phoneNumber.allSatisfy({ $0.isNumber }) else {
            errorMessage = t("invalid_phone", in: "register_screen")
            return
        }

        guard passwordValidator.validatePassword(password) else {
            errorMessage = passwordValidator.errorMessage
            return
        }

        let hashedPassword = hashPassword(password)
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "\(t("register_failed", in: "register_screen")) \(error.localizedDescription)"
                return
            }
            
            guard let user = authResult?.user else {
                errorMessage = t("user_creation_failed", in: "register_screen")
                return
            }
            
            user.sendEmailVerification { verificationError in
                if let verificationError = verificationError {
                    errorMessage = "\(t("email_verification_failed", in: "register_screen")) \(verificationError.localizedDescription)"
                    return
                }
                
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "pass": hashedPassword,
                    "age": ageNum,
                    "sex": sex,
                    "job": job,
                    "height": heightNum,
                    "weight": weightNum,
                    "phone": phoneNumber,
                    "score": 0
                ]
                
                db.collection("users").document(user.uid).setData(userData) { firestoreError in
                    if let firestoreError = firestoreError {
                        errorMessage = "\(t("save_user_failed", in: "register_screen")) \(firestoreError.localizedDescription)"
                    } else {
                        db.collection("users").document(user.uid).collection("mates").document("Bear").setData([
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
    @ObservedObject var language: Language
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                .padding(.vertical, 10)
                .foregroundColor(.primary)
                .keyboardType(keyboardType)
            
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
    @ObservedObject var language: Language
    
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
            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
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
    @ObservedObject var language: Language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Sex", in: "register_screen"))
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(sexOptions, id: \.self) { option in
                    Button(action: {
                        sex = option
                    }) {
                        Text(t(option, in: "register_screen"))
                    }
                }
            } label: {
                HStack {
                    Text(sex.isEmpty ? t("Select", in: "register_screen") : t(sex, in: "register_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
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

// MARK: - Job Picker (Styled)
struct JobPickerView: View {
    @Binding var job: String
    let jobOptions: [String]
    @ObservedObject var language: Language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Job", in: "register_screen"))
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(jobOptions, id: \.self) { option in
                    Button(action: {
                        job = option
                    }) {
                        Text(t(option, in: "register_screen"))
                    }
                }
            } label: {
                HStack {
                    Text(job.isEmpty ? t("Select", in: "register_screen") : t(job, in: "register_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                        .foregroundColor(job.isEmpty ? .gray : .primary)
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
