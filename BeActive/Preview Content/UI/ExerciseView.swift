//
//  ExerciseView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 27/1/2568 BE.


import SwiftUI
import SafariServices

struct Exercise: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let videoURL: String
    var isFavorite: Bool
}

struct ExerciseView: View {
    @StateObject var themeManager = ThemeManager() // ใช้ ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var exercises: [Exercise] = [
        Exercise(title: t("Back Exercise", in: "Ex_screen"), duration: "10 " + t("Minutes", in: "Ex_screen"), videoURL: "https://youtu.be/4BYVwq2wv0Q?si=wfvsQSPgxiIz4Ldj", isFavorite: false),
        Exercise(title: t("Neck Exercise", in: "Ex_screen"), duration: "5 " + t("Minutes", in: "Ex_screen"), videoURL: "https://www.example.com/neck-exercise", isFavorite: false),
        Exercise(title: t("Arm Exercise", in: "Ex_screen"), duration: "7 " + t("Minutes", in: "Ex_screen"), videoURL: "https://www.example.com/arm-exercise", isFavorite: false),
        Exercise(title: t("Shoulder Exercise", in: "Ex_screen"), duration: "5 " + t("Minutes", in: "Ex_screen"), videoURL: "https://www.example.com/shoulder-exercise", isFavorite: false)
    ]
    
    @State private var selectedURL: IdentifiableURL?
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: DeviceHelper.adaptiveSpacing(baseSpacing: 20)) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // ปิดหน้าจอเมื่อกด
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 20)))
                                    .foregroundColor(.blue)
                                Text(t("Back", in: "Ex_screen"))
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                                    .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 18)))
                            }
                        }
                        .padding(.leading, DeviceHelper.adaptivePadding())

                        Spacer()
                    }

                    Text(t("Exercise", in: "Ex_screen"))
                        .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 34), weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, DeviceHelper.adaptivePadding())
                    
                    Text(t("Recommended for you", in: "Ex_screen"))
                        .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 20), weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, DeviceHelper.adaptivePadding())
                        .padding(.top, -DeviceHelper.adaptiveSpacing(baseSpacing: 10))
                        .padding(.bottom, DeviceHelper.adaptiveSpacing(baseSpacing: 10))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DeviceHelper.adaptiveSpacing(baseSpacing: 35)) {
                        ForEach($exercises) { $exercise in
                            ExerciseCard(exercise: $exercise, selectedURL: $selectedURL, themeManager: themeManager)
                        }
                    }
                    .padding(.horizontal, DeviceHelper.adaptivePadding())

                    Text(t("Article & Tip", in: "Ex_screen"))
                        .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 20), weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, DeviceHelper.adaptivePadding())

                    VStack(spacing: DeviceHelper.adaptiveSpacing(baseSpacing: 15)) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: DeviceHelper.adaptiveCornerRadius(baseRadius: 15))
                                .fill(themeManager.textColor.opacity(0.2))
                                .frame(height: DeviceHelper.adaptiveFrameSize(baseSize: 100))
                                .onTapGesture {
                                    print("Go to Tips")
                                }
                        }
                    }
                    .padding(.horizontal, DeviceHelper.adaptivePadding())
                }
                .padding(.bottom, DeviceHelper.adaptiveSpacing(baseSpacing: 20))
            }
            .background(themeManager.backgroundColor)
            .sheet(item: $selectedURL) { identifiableURL in
                SafariView(url: identifiableURL.url)
            }
        }
        .navigationBarHidden(true) // ซ่อน navigation bar
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    @Binding var selectedURL: IdentifiableURL?
    var themeManager: ThemeManager

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DeviceHelper.adaptiveCornerRadius(baseRadius: 15))
                .fill(themeManager.textColor.opacity(0.2))

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .foregroundColor(exercise.isFavorite ? Color.yellow : Color.purple)
                        .padding()
                        .onTapGesture {
                            exercise.isFavorite.toggle()
                        }
                }

                Spacer()

                RoundedRectangle(cornerRadius: 0)
                    .fill(themeManager.textColor.opacity(0.8))
                    .frame(height: DeviceHelper.adaptiveFrameSize(baseSize: 50))

                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.title)
                            .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 18), weight: .semibold))
                            .foregroundColor(.purple)
                        Text(exercise.duration)
                            .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 16)))
                            .foregroundColor(themeManager.backgroundColor)
                    }
                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .foregroundColor(themeManager.textColor)
                        .font(.system(size: DeviceHelper.adaptiveFontSize(baseSize: 22)))
                }
                .padding(.horizontal, DeviceHelper.adaptivePadding())
                .padding(.vertical, DeviceHelper.adaptiveSpacing(baseSpacing: 5))
            }
        }
        .frame(height: DeviceHelper.adaptiveFrameSize(baseSize: 150))
        .padding(.bottom, DeviceHelper.adaptiveSpacing(baseSpacing: 10))
        .onTapGesture {
            if let url = URL(string: exercise.videoURL) {
                selectedURL = IdentifiableURL(url: url)
            }
        }
    }
}

// SafariView to open links inside the app
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}

// Wrapper to make URL identifiable
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
