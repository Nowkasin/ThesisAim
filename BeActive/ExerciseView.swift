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
    @State private var exercises: [Exercise] = [
        Exercise(title: "Back Exercise", duration: "10 Minutes", videoURL: "https://youtu.be/4BYVwq2wv0Q?si=wfvsQSPgxiIz4Ldj", isFavorite: false),
        Exercise(title: "Neck Exercise", duration: "5 Minutes", videoURL: "https://www.example.com/neck-exercise", isFavorite: false),
        Exercise(title: "Arm Exercise", duration: "7 Minutes", videoURL: "https://www.example.com/arm-exercise", isFavorite: false),
        Exercise(title: "Shoulder Exercise", duration: "5 Minutes", videoURL: "https://www.example.com/shoulder-exercise", isFavorite: false)
    ]

    @State private var selectedURL: IdentifiableURL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Exercise")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.purple)
                    .padding(.horizontal)

                Text("Recommended for you")
                    .font(.headline)
                    .foregroundColor(Color.blue)
                    .padding(.horizontal)
                    .padding(.top, -20)
                    .padding(.bottom, 10)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 35) {
                    ForEach($exercises) { $exercise in
                        ExerciseCard(exercise: $exercise, selectedURL: $selectedURL)
                    }
                }
                .padding(.horizontal)

                Text("Article & Tip")
                    .font(.headline)
                    .foregroundColor(Color.blue)
                    .padding(.horizontal)

                VStack(spacing: 15) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .onTapGesture {
                            print("Go to Articles")
                        }

                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .onTapGesture {
                            print("Go to Tips")
                        }
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .onTapGesture {
                            print("Go to Tips")
                        }
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .onTapGesture {
                            print("Go to Tips")
                        }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .sheet(item: $selectedURL) { identifiableURL in
            SafariView(url: identifiableURL.url)
        }
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    @Binding var selectedURL: IdentifiableURL?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.3))

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .foregroundColor(exercise.isFavorite ? Color.indigo : Color.white)
                        .padding()
                        .onTapGesture {
                            exercise.isFavorite.toggle()
                        }
                }

                Spacer()

                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 50)

                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.title)
                            .font(.headline)
                            .foregroundColor(Color.blue)
                        Text(exercise.duration)
                            .foregroundColor(.white)
                    }
                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .foregroundColor(Color.purple)
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

