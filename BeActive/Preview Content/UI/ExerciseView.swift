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
    let previewImageName: String
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
    @State private var selectedArticleURL: IdentifiableURL?
    private let favoriteManager = FavoriteManager()
    @ObservedObject var language: Language

    public init(language: Language) {
        self.language = language
    }

    private var articles: [Article] = [
        Article(title: t("Stretch to Reduce Pain", in: "Articles"), description: t("Stretch to Reduce Pain Desc", in: "Articles"), url: "https://www.prevention.com/fitness/a20505758/deep-stretches-for-everyday-aches-and-pains/"),
        Article(title: t("Guide to Good Posture", in: "Articles"), description: t("Guide to Good Posture Desc", in: "Articles"), url: "https://medlineplus.gov/guidetogoodposture.html"),
        Article(title: t("Preventing Office Syndrome While WFH", in: "Articles"), description: t("Preventing Office Syndrome While WFH Desc", in: "Articles"), url: "https://www.bangkokhospital.com/en/content/work-from-home-and-office-syndrome"),
        Article(title: t("Why Move More?", in: "Articles"), description: t("Why Move More? Desc", in: "Articles"), url: "https://wellbeing.ubc.ca/wellbeing-campaigns-and-initiatives/move-ubc/why-move-more")
    ]

    @State private var exerciseStates: [Exercise] = []

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let cardSpacing: CGFloat = screenWidth > 400 ? 30 : 20
            let padding: CGFloat = screenWidth > 400 ? 24 : 16
            let titleFontSize: CGFloat = screenWidth > 400 ? 34 : 28
            let subTitleFontSize: CGFloat = screenWidth > 400 ? 20 : 18
            let cardWidth = (screenWidth - padding * 2 - cardSpacing) / 2

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
                            cardWidth: cardWidth,
                            onFavoriteToggle: { videoURL in
                                toggleFavorite(for: videoURL)
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
                                            selectedArticleURL = IdentifiableURL(url: url)
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
            }
        }
        .onAppear {
            loadExercises()
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedEmbedURL) { item in
            WebViewPlayer(embedURL: item.url)
                .ignoresSafeArea()
        }
        .sheet(item: $selectedArticleURL) { item in
            WebViewPlayer(embedURL: item.url)
                .ignoresSafeArea()
        }
    }

    private func loadExercises() {
        let savedFavorites = favoriteManager.loadFavorites()
        exerciseStates = [
            Exercise(
                title: t("Back Exercise", in: "Ex_screen"),
                duration: "10 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/g43xYk4VAjU",
                previewImageName: "Bear",
                isFavorite: savedFavorites.contains("https://www.youtube.com/embed/g43xYk4VAjU")
            ),
            Exercise(
                title: t("Neck Exercise", in: "Ex_screen"),
                duration: "5 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/8JNDtye2CB0?si=_ZdNl7uAGXTkpm-0",
                previewImageName: "neck_exercise",
                isFavorite: savedFavorites.contains("https://www.youtube.com/embed/8JNDtye2CB0?si=_ZdNl7uAGXTkpm-0")
            ),
            Exercise(
                title: t("Arm Exercise", in: "Ex_screen"),
                duration: "7 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/TSrfB7JIzxY",
                previewImageName: "arm_exercise",
                isFavorite: savedFavorites.contains("https://www.youtube.com/embed/TSrfB7JIzxY")
            ),
            Exercise(
                title: t("Shoulder Exercise", in: "Ex_screen"),
                duration: "5 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/2VuLBYrgG94",
                previewImageName: "shoulder_exercise",
                isFavorite: savedFavorites.contains("https://www.youtube.com/embed/2VuLBYrgG94")
            ),
            Exercise(
                title: t("Chest Exercise", in: "Ex_screen"),
                duration: "5 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/d2ZYz9RmYk0",
                previewImageName: "chest_stretch",
                isFavorite: savedFavorites.contains("https://www.youtube.com/embed/d2ZYz9RmYk0")
            ),
            Exercise(
                title: t("Eye Exercise", in: "Ex_screen"),
                duration: "3 " + t("Minutes", in: "Ex_screen"),
                videoURL: "https://www.youtube.com/embed/6SB3w5Sb0hQ",
                previewImageName: "eye_exercise",
                isFavorite: savedFavorites.contains("https://www.youtube.com/embed/6SB3w5Sb0hQ")
            )
        ]
    }

    private func toggleFavorite(for videoURL: String) {
        var favorites = favoriteManager.loadFavorites()
        if favorites.contains(videoURL) {
            favorites.remove(videoURL)
        } else {
            favorites.insert(videoURL)
        }
        favoriteManager.saveFavorites(favorites)
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    @Binding var selectedEmbedURL: IdentifiableURL?
    var cardWidth: CGFloat
    var onFavoriteToggle: ((String) -> Void)? = nil
    @ObservedObject var language: Language

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(named: exercise.previewImageName) ?? UIImage(named: "no_preview") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardWidth, height: cardWidth * 0.6)
                        .clipped()
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                } else {
                    Color.gray
                        .frame(width: cardWidth, height: cardWidth * 0.6)
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                }

                Button(action: {
                    exercise.isFavorite.toggle()
                    onFavoriteToggle?(exercise.videoURL)
                }) {
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(exercise.isFavorite ? .yellow : .purple)
                        .padding(8)
//                        .background(Color.white.opacity(0.9))
//                        .clipShape(Circle())
//                        .shadow(radius: 3)
//                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                    .foregroundColor(.purple)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(exercise.duration)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                    .foregroundColor(.purple.opacity(0.8))
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack {
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.purple)
                }
            }
            .padding(10)
            .frame(width: cardWidth)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
            .contentShape(Rectangle())
            .onTapGesture {
                if let url = URL(string: exercise.videoURL) {
                    selectedEmbedURL = IdentifiableURL(url: url)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
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
                previewImageName: "back_exercise",
                isFavorite: false
            )),
            selectedEmbedURL: .constant(nil),
            cardWidth: 180,
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
