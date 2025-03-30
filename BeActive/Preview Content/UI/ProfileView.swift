//
//  ProfileView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/2/2568 BE.
//

// Minimalist Card Design
import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var healthData: HealthDataManager
    @State private var localHealthStats = HealthStats.placeholder
    let db = Firestore.firestore()
    
    // ✅ ข้อมูลผู้ใช้
    @State private var userName: String = "No user data"
    @State private var userAge: Int?
    @State private var userEmail: String = "No email"
    @State private var userHeight: Int?
    @State private var userPhone: String = "No phone"
    @State private var userSex: String = "No sex info"
    @State private var userWeight: Int?
    @State private var errorMessage: String?
    
    // ✅ เปิดหน้าแก้ไขโปรไฟล์
    @State private var isEditingProfile = false

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeader(userName: userName, userAge: userAge)

                    // 🔹 ปุ่ม "Edit Profile"
                    Button(action: {
                        isEditingProfile = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .medium))
                            Text("Edit Profile")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
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
                            userWeight: $userWeight
                        )
                    }

                    InfoCard(title: "User Information", icon: "person.fill") {
                        UserInfoRow(icon: "envelope.fill", title: "Email", value: userEmail)
                        if let height = userHeight { UserInfoRow(icon: "ruler.fill", title: "Height", value: "\(height) cm") }
                        UserInfoRow(icon: "phone.fill", title: "Phone", value: userPhone)
                        UserInfoRow(icon: "person.fill", title: "Sex", value: userSex)
                        if let weight = userWeight { UserInfoRow(icon: "scalemass.fill", title: "Weight", value: "\(weight) kg") }
                    }
                    
                    InfoCard(title: "Health Stats", icon: "heart.fill") {
                        HealthStatView(icon: "heart.fill", color: .red, title: "Heart Rate", value: localHealthStats.heartRate)
                        HealthStatView(icon: "figure.walk", color: .green, title: "Steps", value: localHealthStats.stepCount)
                        HealthStatView(icon: "flame.fill", color: .orange, title: "Calories", value: localHealthStats.caloriesBurned)
                        HealthStatView(icon: "figure.walk.circle", color: .blue, title: "Distance", value: localHealthStats.distance)
                    }
                    
                    // 🔴 **ปุ่ม Logout**
                    Button(action: {
                        print("🔴 Logout Button Pressed") // ✅ ยังไม่มี FirebaseAuth ใช้ print ก่อน
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
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
        db.collection("users").document("user1").getDocument { document, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.errorMessage = "Error: \(error!.localizedDescription)"
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

// ✅ **หน้าสำหรับแก้ไขข้อมูลผู้ใช้**
struct EditProfileView: View {
    @Binding var userName: String
    @Binding var userAge: Int?
    @Binding var userEmail: String
    @Binding var userHeight: Int?
    @Binding var userPhone: String
    @Binding var userSex: String
    @Binding var userWeight: Int?

    let db = Firestore.firestore()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information").font(.headline)) {
                    LabeledTextField(label: "Full Name", text: $userName)
                    LabeledTextField(label: "Email Address", text: $userEmail)
                        .keyboardType(.emailAddress)
                    LabeledTextField(label: "Phone Number", text: $userPhone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Physical Information").font(.headline)) {
                    LabeledNumberField(label: "Age", value: $userAge)
                    LabeledNumberField(label: "Height (cm)", value: $userHeight)
                    LabeledNumberField(label: "Weight (kg)", value: $userWeight)

                    Picker("Sex", selection: $userSex) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button(action: {
                        saveUserData()
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveUserData() {
        let updatedData: [String: Any] = [
            "name": userName,
            "age": userAge ?? 0,
            "email": userEmail,
            "height": userHeight ?? 0,
            "phone": userPhone,
            "sex": userSex,
            "weight": userWeight ?? 0
        ]

        db.collection("users").document("user1").setData(updatedData) { error in
            if let error = error {
                print("❌ Error updating user: \(error.localizedDescription)")
            } else {
                print("✅ User data successfully updated!")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


// ✅ **TextField แบบมี Label**
struct LabeledTextField: View {
    var label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(label, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 5)
    }
}

// ✅ **TextField สำหรับตัวเลข**
struct LabeledNumberField: View {
    var label: String
    @Binding var value: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(label, value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 5)
    }
}


// ✅ UI ส่วน Header
struct ProfileHeader: View {
    var userName: String
    var userAge: Int?
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 5)

            Text(userName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let age = userAge {
                Text("Age: \(age)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}


// ✅ UI CardView (แก้ไขให้ใช้ @ViewBuilder)
struct InfoCard<Content: View>: View {
    var title: String
    var icon: String
    @ViewBuilder var content: () -> Content  // ✅ ใช้ @ViewBuilder

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            .padding(.bottom, 5)
            
            Group {  // ✅ ใช้ Group ป้องกัน SwiftUI แปลผิด
                content()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 3))
        .padding(.horizontal)
    }
}


// ✅ UI ของข้อมูลผู้ใช้
struct UserInfoRow: View {
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 30)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

// ✅ UI ของ HealthStatView
struct HealthStatView: View {
    var icon: String
    var color: Color
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// ✅ Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(HealthDataManager())
    }
}
