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
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedURL: IdentifiableURL?

    private var exercises: [Exercise] = [
        Exercise(title: t("Back Exercise", in: "Ex_screen"), duration: "10 " + t("Minutes", in: "Ex_screen"), videoURL: "https://youtu.be/4BYVwq2wv0Q", isFavorite: false),
        Exercise(title: t("Neck Exercise", in: "Ex_screen"), duration: "5 " + t("Minutes", in: "Ex_screen"), videoURL: "https://www.example.com/neck-exercise", isFavorite: false),
        Exercise(title: t("Arm Exercise", in: "Ex_screen"), duration: "7 " + t("Minutes", in: "Ex_screen"), videoURL: "https://www.example.com/arm-exercise", isFavorite: false),
        Exercise(title: t("Shoulder Exercise", in: "Ex_screen"), duration: "5 " + t("Minutes", in: "Ex_screen"), videoURL: "https://www.example.com/shoulder-exercise", isFavorite: false)
    ]

    @State private var exerciseStates: [Exercise]

    init() {
        _exerciseStates = State(initialValue: exercises)
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let cardHeight: CGFloat = screenWidth > 400 ? 180 : 150
            let cardSpacing: CGFloat = screenWidth > 400 ? 30 : 20
            let padding: CGFloat = screenWidth > 400 ? 24 : 16
            let titleFontSize: CGFloat = screenWidth > 400 ? 34 : 28
            let subTitleFontSize: CGFloat = screenWidth > 400 ? 20 : 18

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: cardSpacing) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20))
                                    Text(t("Back", in: "Ex_screen"))
                                        .fontWeight(.semibold)
                                        .font(.system(size: 18))
                                }
                                .foregroundColor(.blue)
                            }
                            .padding(.leading, padding)

                            Spacer()
                        }

                        Text(t("Exercise", in: "Ex_screen"))
                            .font(.system(size: titleFontSize, weight: .bold))
                            .foregroundColor(.purple)
                            .padding(.horizontal, padding)

                        Text(t("Recommended for you", in: "Ex_screen"))
                            .font(.system(size: subTitleFontSize, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, padding)
                            .padding(.top, -10)
                            .padding(.bottom, 10)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: cardSpacing) {
                            ForEach($exerciseStates) { $exercise in
                                ExerciseCard(exercise: $exercise, selectedURL: $selectedURL, cardHeight: cardHeight)
                            }
                        }
                        .padding(.horizontal, padding)

                        Text(t("Article & Tip", in: "Ex_screen"))
                            .font(.system(size: subTitleFontSize, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, padding)

                        VStack(spacing: 15) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.primary.opacity(0.1))
                                    .frame(height: 100)
                                    .onTapGesture {
                                        print("Go to Tips")
                                    }
                            }
                        }
                        .padding(.horizontal, padding)

                        Spacer().frame(height: 30)
                    }
                }
                .sheet(item: $selectedURL) { identifiableURL in
                    SafariView(url: identifiableURL.url)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    @Binding var selectedURL: IdentifiableURL?
    var cardHeight: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .foregroundColor(exercise.isFavorite ? Color.yellow : .purple)
                        .padding()
                        .onTapGesture {
                            exercise.isFavorite.toggle()
                        }
                }

                Spacer()

                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.purple.opacity(0.8))
                    .frame(height: 50)

                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.purple)
                        Text(exercise.duration)
                            .font(.system(size: 16))
                            .foregroundColor(.purple.opacity(0.9))
                    }

                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 22))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
        }
        .frame(height: cardHeight)
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

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}


struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
