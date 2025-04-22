//
//  ProfileView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/2/2568 BE.
//

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var healthData: HealthDataManager
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    @State private var localHealthStats = HealthStats.placeholder
    let db = Firestore.firestore()
    
    @State private var userName: String = "No user data"
    @State private var userAge: Int?
    @State private var userEmail: String = "No email"
    @State private var userHeight: Int?
    @State private var userPhone: String = "No phone"
    @State private var userSex: String = "No sex info"
    @State private var userWeight: Int?
    @State private var errorMessage: String?
    
    @State private var isEditingProfile = false
    @ObservedObject var language = Language.shared

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeader(userName: userName, userAge: userAge, language: language)

                    Button(action: {
                        isEditingProfile = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .medium))
                            Text(t("Edit Profile", in: "Profile_screen"))
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $isEditingProfile) {
                        EditProfileView(
                            userName: $userName,
                            userAge: $userAge,
                            userEmail: $userEmail,
                            userHeight: $userHeight,
                            userPhone: $userPhone,
                            userSex: $userSex,
                            userWeight: $userWeight,
                            language: language
                        )
                    }

                    InfoCard(title: t("User Information", in: "Profile_screen"), icon: "person.fill", language: language) {
                        UserInfoRow(icon: "envelope.fill", title: t("Email", in: "Profile_screen"), value: userEmail, language: language)
                        if let height = userHeight {
                            UserInfoRow(
                                icon: "ruler.fill",
                                title: t("Height", in: "Profile_screen"),
                                value: "\(height) \(t("cm", in: "Profile_screen"))",
                                language: language
                            )
                        }
                        UserInfoRow(icon: "phone.fill", title: t("Phone", in: "Profile_screen"), value: userPhone, language: language)
                        UserInfoRow(icon: "person.fill", title: t("Sex", in: "Profile_screen"),  value: t(userSex, in: "Profile_screen.SEX"), language: language)

                        if let weight = userWeight {
                            UserInfoRow(
                                icon: "scalemass.fill",
                                title: t("Weight", in: "Profile_screen"),
                                value: "\(weight) \(t("kg", in: "Profile_screen"))",
                                language: language
                            )
                        }
                    }

                    InfoCard(title: t("Health Stats", in: "Profile_screen"), icon: "heart.fill", language: language) {
                        HealthStatView(icon: "heart.fill", color: .red, title: t("Heart Rate", in: "Profile_screen"), value: localHealthStats.heartRate, language: language)
                        HealthStatView(icon: "figure.walk", color: .green, title: t("Steps", in: "Profile_screen"), value: localHealthStats.stepCount, language: language)
                        HealthStatView(icon: "flame.fill", color: .orange, title: t("Calories", in: "Profile_screen"), value: localHealthStats.caloriesBurned, language: language)
                        HealthStatView(icon: "figure.walk.circle", color: .blue, title: t("Distance", in: "Profile_screen"), value: localHealthStats.distance, language: language)
                    }

                    Button(action: {
                        currentUserId = ""
                        isLoggedIn = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            Text(t("Log Out", in: "Profile_screen"))
                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                Spacer()
            }
        }
        .onAppear {
            Task {
                await fetchProfileData()
            }
            getUserDataFromFirestore()
        }
        .onChange(of: healthData.healthStats) { newStats in
            if localHealthStats != newStats {
                localHealthStats = newStats
            }
        }
    }

    private func fetchProfileData() async {
        await healthData.fetchHealthData()
        DispatchQueue.main.async {
            if self.localHealthStats != healthData.healthStats {
                self.localHealthStats = healthData.healthStats
            }
        }
    }

    private func getUserDataFromFirestore() {
        guard !currentUserId.isEmpty else {
            self.errorMessage = "User not logged in"
            return
        }

        db.collection("users").document(currentUserId).getDocument { document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                guard let document = document, document.exists, let data = document.data() else {
                    self.errorMessage = "User not found"
                    return
                }

                self.userName = data["name"] as? String ?? "No name"
                self.userAge = data["age"] as? Int
                self.userEmail = data["email"] as? String ?? "No email"
                self.userHeight = data["height"] as? Int
                self.userPhone = data["phone"] as? String ?? "No phone"
                self.userSex = data["sex"] as? String ?? "No sex info"
                self.userWeight = data["weight"] as? Int
                self.errorMessage = nil
            }
        }
    }
}


struct EditProfileView: View {
    @Binding var userName: String
    @Binding var userAge: Int?
    @Binding var userEmail: String
    @Binding var userHeight: Int?
    @Binding var userPhone: String
    @Binding var userSex: String
    @Binding var userWeight: Int?
    var language: Language

    let db = Firestore.firestore()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(t("Personal Information", in: "Profile_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                ) {
                    LabeledTextField(label: t("Full Name", in: "Profile_screen"), text: $userName, language: language)
                    LabeledTextField(label: t("Email", in: "Profile_screen"), text: $userEmail, language: language)
                    LabeledTextField(label: t("Phone", in: "Profile_screen"), text: $userPhone, language: language)
                }

                Section(header: Text(t("Physical Information", in: "Profile_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                ) {
                    LabeledNumberField(label: t("Age", in: "register_screen"), value: $userAge, language: language)
                    LabeledNumberField(label: t("Height (cm)", in: "register_screen"), value: $userHeight, language: language)
                    LabeledNumberField(label: t("Weight (kg)", in: "register_screen"), value: $userWeight, language: language)

                    Picker(t("Sex", in: "register_screen"), selection: $userSex) {
                        Text(t("Male", in: "register_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                            .tag("Male")
                        Text(t("Female", in: "register_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                            .tag("Female")
                        Text(t("Other", in: "register_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                            .tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button(action: {
                        saveUserData()
                    }) {
                        Text(t("Save Changes", in: "Profile_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
            }
            .navigationTitle(
                Text(t("Edit Profile", in: "Profile_screen"))
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
            )
            .navigationBarItems(trailing:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(t("Cancel", in: "Mate_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                }
            )
        }
    }

    private func saveUserData() {
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("❌ User ID not found")
            return
        }

        let updatedData: [String: Any] = [
            "name": userName,
            "age": userAge ?? 0,
            "email": userEmail,
            "height": userHeight ?? 0,
            "phone": userPhone,
            "sex": userSex,
            "weight": userWeight ?? 0
        ]

        db.collection("users").document(userId).setData(updatedData) { error in
            if let error = error {
                print("❌ Error updating user: \(error.localizedDescription)")
            } else {
                print("✅ User data successfully updated!")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ProfileHeader: View {
    var userName: String
    var userAge: Int?
    var language: Language

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 5)

            Text(userName)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 28))
                .fontWeight(.bold)
                .foregroundColor(.primary)

            if let age = userAge {
                Text("\(t("Age", in: "register_screen")): \(age)")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct InfoCard<Content: View>: View {
    var title: String
    var icon: String
    var language: Language
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.title2)
                Text(title)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
            }
            .padding(.bottom, 5)

            Group {
                content()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

struct UserInfoRow: View {
    var icon: String
    var title: String
    var value: String
    var language: Language

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 30)

            Text(title)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .foregroundColor(.secondary)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
        }
        .padding(.horizontal)
    }
}

struct HealthStatView: View {
    var icon: String
    var color: Color
    var title: String
    var value: String
    var language: Language

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.bold)
                Text(value)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LabeledTextField: View {
    var label: String
    @Binding var text: String
    var language: Language

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                .foregroundColor(.gray)
            TextField(label, text: $text)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 5)
    }
}

struct LabeledNumberField: View {
    var label: String
    @Binding var value: Int?
    var language: Language

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                .foregroundColor(.gray)
            TextField(label, value: $value, formatter: NumberFormatter())
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 5)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView()
                .environmentObject(HealthDataManager())
                .preferredColorScheme(.light)

            ProfileView()
                .environmentObject(HealthDataManager())
                .preferredColorScheme(.dark)
        }
    }
}


