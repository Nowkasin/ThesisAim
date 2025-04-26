//
//  ProfileView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/2/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import TOCropViewController

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

    // Image picker & cropper states
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: UIImage?
    @State private var profileImageUrl: String?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingActionSheet = false
    @State private var isCropping = false
    @State private var croppedImage: UIImage?
    @State private var didCropImage = false
    @State private var isLoadingCropper = false

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeader(userName: userName, userAge: userAge, profileImage: profileImage, language: language)
                        .onTapGesture {
                            showingActionSheet = true
                        }
                        .actionSheet(isPresented: $showingActionSheet) {
                            ActionSheet(title: Text(t("Select Image", in: "Profile_screen")), buttons: [
                                .default(Text(t("Camera", in: "Profile_screen"))) {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        sourceType = .camera
                                        showingImagePicker = true
                                    } else {
                                        print("❌ Camera not available")
                                    }
                                },
                                .default(Text(t("Photo Library", in: "Profile_screen"))) {
                                    sourceType = .photoLibrary
                                    showingImagePicker = true
                                },
                                .cancel(Text(t("Cancel", in: "Profile_screen")))
                            ])
                        }
                        .sheet(isPresented: $showingImagePicker, onDismiss: {
                            if let originalImage = inputImage {
                                if let resized = originalImage.resized(toMaxSize: 1024) {
                                    inputImage = resized
                                }
                                isLoadingCropper = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    isLoadingCropper = false
                                    isCropping = true
                                }
                            }
                        }) {
                            ImagePicker(image: $inputImage, sourceType: sourceType)
                        }
                        .fullScreenCover(isPresented: $isCropping, onDismiss: {
                            if didCropImage {
                                uploadProfileImageToCloudinary()
                            }
                            didCropImage = false
                        }) {
                            if let inputImage = inputImage {
                                CropViewControllerWrapper(image: inputImage) { cropped in
                                    self.inputImage = cropped
                                    self.profileImage = cropped
                                    self.isCropping = false
                                    self.didCropImage = true
                                }
                            }
                        }

                    Button(action: {
                        isEditingProfile = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .medium))
                            .padding(7)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
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
        .overlay(
            Group {
                if isLoadingCropper {
                    ZStack {
                        Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(isLoadingCropper ? 1.2 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: isLoadingCropper
                                )
                            Text(t("Preparing Image", in: "Profile_screen"))
                                .foregroundColor(.white)
                                .font(.headline)
                                .opacity(0.8)
                        }
                    }
                }
            }
        )
        .onAppear {
            Task {
                await fetchProfileData()
            }
            getUserDataFromFirestore()
            fetchProfileImageIfNeeded()
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
                self.profileImageUrl = data["profileImageUrl"] as? String
                self.errorMessage = nil
                self.fetchProfileImageIfNeeded()
            }
        }
    }

    private func uploadProfileImage() {
        guard let inputImage = inputImage else { return }
        profileImage = inputImage

        guard let imageData = inputImage.jpegData(compressionQuality: 0.5) else { return }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("profile_images/\(currentUserId).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Error uploading profile image: \(error.localizedDescription)")
                return
            }

            guard metadata != nil else {
                print("❌ Upload completed but metadata is nil (upload failed silently)")
                return
            }

            // Slight delay to ensure upload completes properly before requesting download URL
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("❌ Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    if let downloadURL = url {
                        print("✅ Got download URL: \(downloadURL.absoluteString)")
                        saveProfileImageURL(url: downloadURL)
                    }
                }
            }
        }
    }

    private func saveProfileImageURL(url: URL) {
        let db = Firestore.firestore()
        print("🔥 Trying to save profileImageUrl for userId:", currentUserId)
        print("🔥 URL to save:", url.absoluteString)
        db.collection("users").document(currentUserId).updateData([
            "profileImageUrl": url.absoluteString
        ]) { error in
            if let error = error {
                print("❌ Firestore update error: \(error.localizedDescription)")
            } else {
                print("✅ Firestore update success")
                // Optionally update UI
                self.profileImageUrl = url.absoluteString
                self.fetchProfileImageIfNeeded()
            }
        }
    }

    private func fetchProfileImageIfNeeded() {
        guard let urlString = profileImageUrl, let url = URL(string: urlString), profileImage == nil else { return }
        // Download and set profileImage from URL
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }.resume()
    }

    // Upload profile image to Cloudinary and save URL to Firestore
    private func uploadProfileImageToCloudinary() {
        guard let inputImage = inputImage else { return }
        profileImage = inputImage

        guard let imageData = inputImage.jpegData(compressionQuality: 0.5) else { return }

        let url = URL(string: "https://api.cloudinary.com/v1_1/dhkuiwxxz/image/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("AimMatesUpload\r\n".data(using: .utf8)!)

        let timestamp = Int(Date().timeIntervalSince1970)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"public_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(currentUserId)-\(timestamp)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Upload error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data received from Cloudinary")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let imageUrl = json["secure_url"] as? String {
                    print("✅ Uploaded to Cloudinary. Image URL: \(imageUrl)")
                    let refreshedUrl = URL(string: imageUrl + "?v=\(Int.random(in: 1000...9999))")!
                    saveProfileImageURL(url: refreshedUrl)
                } else {
                    print("❌ Unexpected response from Cloudinary")
                }
            } catch {
                print("❌ JSON parse error:", error.localizedDescription)
            }
        }.resume()
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
                    VStack(alignment: .leading) {
                        Text(t("Email", in: "Profile_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                            .foregroundColor(.gray)
                        Text(userEmail)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 5)
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
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(t("Edit Profile", in: "Profile_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 20))
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(t("Cancel", in: "Mate_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    }
                }
            }
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

        db.collection("users").document(userId).setData(updatedData, merge: true) { error in
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
    var profileImage: UIImage?
    var language: Language

    var body: some View {
        VStack {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .shadow(radius: 5)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .shadow(radius: 5)
            }

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
// MARK: - ImagePicker
import UIKit
struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.image = nil
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}



// MARK: - UIImage Resize Extension
import UIKit
extension UIImage {
    func resized(toMaxSize maxSize: CGFloat) -> UIImage? {
        let maxDimension = max(size.width, size.height)
        let scale = (maxDimension > maxSize) ? (maxSize / maxDimension) : 1.0
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}

// MARK: - TOCropViewController SwiftUI Wrapper
import UIKit
struct CropViewControllerWrapper: UIViewControllerRepresentable {
    var image: UIImage
    var onCrop: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = context.coordinator
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetButtonHidden = true
        cropViewController.modalTransitionStyle = .crossDissolve
        cropViewController.modalPresentationStyle = .fullScreen
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: CropViewControllerWrapper

        init(_ parent: CropViewControllerWrapper) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.onCrop(image)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
