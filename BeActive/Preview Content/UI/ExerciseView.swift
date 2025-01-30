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
                VStack(alignment: .leading, spacing: 20) {
                    Text(t("Exercise", in: "Ex_screen"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.purple)
                        .padding(.horizontal)
                    
                    Text(t("Recommended for you", in: "Ex_screen"))
                        .font(.headline)
                        .foregroundColor(Color.blue)
                        .padding(.horizontal)
                        .padding(.top, -20)
                        .padding(.bottom, 10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 35) {
                        ForEach($exercises) { $exercise in
                            ExerciseCard(exercise: $exercise, selectedURL: $selectedURL, themeManager: themeManager)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text(t("Article & Tip", in: "Ex_screen"))
                        .font(.headline)
                        .foregroundColor(Color.blue)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(themeManager.textColor.opacity(0.2))
                                .frame(height: 100)
                                .onTapGesture {
                                    print("Go to Tips")
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(themeManager.backgroundColor)
            .sheet(item: $selectedURL) { identifiableURL in
                SafariView(url: identifiableURL.url)
            }
        }
    }
}

       

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    @Binding var selectedURL: IdentifiableURL?
    var themeManager: ThemeManager

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(themeManager.textColor.opacity(0.2))

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .foregroundColor(exercise.isFavorite ? Color.yellow : themeManager.textColor)
                        .padding()
                        .onTapGesture {
                            exercise.isFavorite.toggle()
                        }
                }

                Spacer()

                RoundedRectangle(cornerRadius: 0)
                    .fill(themeManager.textColor.opacity(0.8))
                    .frame(height: 50)

                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.title)
                            .font(.headline)
                            .foregroundColor(themeManager.textColor)
                        Text(exercise.duration)
                            .foregroundColor(themeManager.backgroundColor)
                    }
                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .foregroundColor(themeManager.textColor)
                        .font(.title)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .frame(height: 150)
        .padding(.bottom, 10)
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
