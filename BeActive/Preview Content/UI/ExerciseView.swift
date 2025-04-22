//
//  ExerciseView.swift
//  BeActive
//
//  Created by Thanawat Sriwanlop on 27/1/2568 BE.


import SwiftUI
import WebKit

struct Exercise: Identifiable, Codable {
    let id = UUID()
    let title: String
    let duration: String
    let videoURL: String
    var isFavorite: Bool
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: String
}

class FavoriteManager {
    private let key = "favoriteExercises"

    func loadFavorites() -> Set<String> {
        let titles = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(titles)
    }

    func saveFavorites(_ favorites: Set<String>) {
        UserDefaults.standard.set(Array(favorites), forKey: key)
    }
}

struct ExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedEmbedURL: IdentifiableURL?
    private let favoriteManager = FavoriteManager()
    @ObservedObject var language: Language

    public init(language: Language) {
        self.language = language
    }

    private var articles: [Article] = [
        Article(title: "Stretch to Reduce Pain", description: "Easy office stretches to relieve tension in your neck and back.", url: "https://www.example.com/stretch-tips"),
        Article(title: "Perfect Posture", description: "Tips for improving posture while working at a desk.", url: "https://www.example.com/posture-tips"),
        Article(title: "Break Time Ideas", description: "Simple routines to do during work breaks to keep your body active.", url: "https://www.example.com/break-ideas"),
        Article(title: "Why Move More?", description: "Health benefits of standing up and walking during work.", url: "https://www.example.com/why-move")
    ]

    @State private var exerciseStates: [Exercise] = []

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
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                                }
                                .foregroundColor(.blue)
                            }
                            .padding(.leading, padding)

                            Spacer()
                        }

                        Text(t("Exercise", in: "Ex_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: titleFontSize))
                            .foregroundColor(.purple)
                            .padding(.horizontal, padding)

                        Text(t("Recommended for you", in: "Ex_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: subTitleFontSize))
                            .foregroundColor(.blue)
                            .padding(.horizontal, padding)
                            .padding(.top, -10)
                            .padding(.bottom, 10)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: cardSpacing) {
                            ForEach($exerciseStates) { $exercise in
                                ExerciseCard(
                                    exercise: $exercise,
                                    selectedEmbedURL: $selectedEmbedURL,
                                    cardHeight: cardHeight,
                                    onFavoriteToggle: { title in
                                        toggleFavorite(for: title)
                                    },
                                    language: language
                                )
                            }
                        }
                        .padding(.horizontal, padding)

                        Text(t("Article & Tip", in: "Ex_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: subTitleFontSize))
                            .foregroundColor(.blue)
                            .padding(.horizontal, padding)

                        VStack(spacing: 15) {
                            ForEach(articles) { article in
                                ArticleCard(
                                    article: article,
                                    onTap: {
                                        if let url = URL(string: article.url) {
                                            UIApplication.shared.open(url)
                                        }
                                    },
                                    language: language
                                )
                            }
                        }
                        .padding(.horizontal, padding)

                        Spacer().frame(height: 30)
                        Color.clear.frame(height: 30)
                    }
                }
                .sheet(item: $selectedEmbedURL) { item in
                    WebViewPlayer(embedURL: item.url)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            loadExercises()
        }
        .navigationBarHidden(true)
    }

    private func loadExercises() {
        let savedFavorites = favoriteManager.loadFavorites()
        exerciseStates = [
            Exercise(
                title: t("Back Exercise", in: "Ex_screen"),
                duration: "10 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/g43xYk4VAjU",
                isFavorite: savedFavorites.contains(t("Back Exercise", in: "Ex_screen"))
            ),
            Exercise(
                title: t("Neck Exercise", in: "Ex_screen"),
                duration: "5 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/8JNDtye2CB0?si=_ZdNl7uAGXTkpm-0",
                isFavorite: savedFavorites.contains(t("Neck Exercise", in: "Ex_screen"))
            ),
            Exercise(
                title: t("Arm Exercise", in: "Ex_screen"),
                duration: "7 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/TSrfB7JIzxY",
                isFavorite: savedFavorites.contains(t("Arm Exercise", in: "Ex_screen"))
            ),
            Exercise(
                title: t("Shoulder Exercise", in: "Ex_screen"),
                duration: "5 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/2VuLBYrgG94",
                isFavorite: savedFavorites.contains(t("Shoulder Exercise", in: "Ex_screen"))
            )
        ]
    }

    private func toggleFavorite(for title: String) {
        var favorites = favoriteManager.loadFavorites()
        if favorites.contains(title) {
            favorites.remove(title)
        } else {
            favorites.insert(title)
        }
        favoriteManager.saveFavorites(favorites)
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    @Binding var selectedEmbedURL: IdentifiableURL?
    var cardHeight: CGFloat
    var onFavoriteToggle: ((String) -> Void)? = nil
    @ObservedObject var language: Language

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
                .shadow(radius: 3)

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .foregroundColor(exercise.isFavorite ? Color.yellow : .purple)
                        .padding()
                        .scaleEffect(exercise.isFavorite ? 1.2 : 1)
                        .animation(.spring(), value: exercise.isFavorite)
                        .onTapGesture {
                            exercise.isFavorite.toggle()
                            onFavoriteToggle?(exercise.title)
                        }
                }

                Spacer()

                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.purple.opacity(0.8))
                    .frame(height: 50)

                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.title)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                            .foregroundColor(.purple)
                        Text(exercise.duration)
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
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
                selectedEmbedURL = IdentifiableURL(url: url)
            }
        }
    }
}

struct ArticleCard: View {
    var article: Article
    var onTap: () -> Void
    @ObservedObject var language: Language

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                .foregroundColor(.primary)
            Text(article.description)
                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(height: 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(15)
        .onTapGesture {
            onTap()
        }
    }
}

struct WebViewPlayer: UIViewRepresentable {
    let embedURL: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: embedURL)
        uiView.scrollView.isScrollEnabled = false
        uiView.load(request)
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(language: Language.shared)
    }
}

struct ExerciseCard_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCard(
            exercise: .constant(Exercise(
                title: "Sample Exercise",
                duration: "10 Minutes",
                videoURL: "https://www.example.com",
                isFavorite: false
            )),
            selectedEmbedURL: .constant(nil),
            cardHeight: 180,
            language: Language.shared
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

struct ArticleCard_Previews: PreviewProvider {
    static var previews: some View {
        ArticleCard(
            article: Article(
                title: "Sample Article",
                description: "Quick tips to relieve back pain while working.",
                url: "https://www.example.com/article"
            ),
            onTap: {},
            language: Language.shared
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
