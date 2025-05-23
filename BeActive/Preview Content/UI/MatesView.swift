//
//  MatesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

// MARK: - Mate Model
struct Mate: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let cost: Int
    let imageUrl: URL

    init(id: UUID = UUID(), name: String, cost: Int, imageUrl: URL) {
        self.id = id
        self.name = name
        self.cost = cost
        self.imageUrl = imageUrl
    }
}

// MARK: - MatesView
struct MatesView: View {
    @ObservedObject var language = Language.shared
    @EnvironmentObject var scoreManager: ScoreManager
    @AppStorage("purchasedMatesData") private var purchasedMatesData: Data = Data()
    @AppStorage("currentUserId") private var currentUserId: String = ""

    @State private var selectedMate: Mate? = nil
    @State private var showConfirm = false
    @State private var showInsufficientPoints = false
    @State private var showAlreadyOwnedAlert = false
    @State private var selectedTab = 0

    @State private var purchasedMateIDs: Set<UUID> = []
    
    @State private var showPromo: Bool = false
    @State private var promoMate: Mate? = nil
    @AppStorage("lastPromoDate") private var lastPromoDate: String = ""

    let mates: [Mate] = [
        Mate(name: "Happy Bear", cost: 1500, imageUrl: URL(string: "https://i.imgur.com/mTEiOqd.png")!),
        Mate(name: "Lovely Bear", cost: 2500, imageUrl: URL(string: "https://i.imgur.com/OT2vJPe.png")!),
        Mate(name: "Chick", cost: 1000, imageUrl: URL(string: "https://i.imgur.com/ay4YRSm.png")!),
        Mate(name: "Happy Chick", cost: 3000, imageUrl: URL(string: "https://i.imgur.com/YBn2oFH.png")!),
        Mate(name: "Lovely Chick", cost: 5000, imageUrl: URL(string: "https://i.imgur.com/YPFM2Bu.png")!),
        Mate(name: "Bunny", cost: 3000, imageUrl: URL(string: "https://i.imgur.com/if52U93.png")!),
        Mate(name: "Happy Bunny", cost: 5000, imageUrl: URL(string: "https://i.imgur.com/ZZlNIjX.png")!),
        Mate(name: "Lovely Bunny", cost: 7000, imageUrl: URL(string: "https://i.imgur.com/VLvp9Qm.png")!),
        Mate(name: "Dog", cost: 5000, imageUrl: URL(string: "https://i.imgur.com/RObtJjY.png")!),
        Mate(name: "Happy Dog", cost: 7000, imageUrl: URL(string: "https://i.imgur.com/YiEE02e.png")!),
        Mate(name: "Lovely Dog", cost: 9000, imageUrl: URL(string: "https://i.imgur.com/y3ocZ22.png")!),
        Mate(name: "Cat", cost: 7000, imageUrl: URL(string: "https://i.imgur.com/5ym20Wl.png")!),
        Mate(name: "Happy Cat", cost: 9000, imageUrl: URL(string: "https://i.imgur.com/0JJOJbK.png")!),
        Mate(name: "Lovely Cat", cost: 11000, imageUrl: URL(string: "https://i.imgur.com/TRIDeEw.png")!),
        Mate(name: "Mocha", cost: 999999, imageUrl: URL(string: "https://i.imgur.com/EmIC3a0.png")!),
        Mate(name: "Death Bear", cost: 0, imageUrl: URL(string: "https://i.imgur.com/vBeXvPT.png")!)
    ]

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    private func maybeShowPromo() {
        print("📢 maybeShowPromo called")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        let hour = Calendar.current.component(.hour, from: Date())
        guard let deathBear = mates.first(where: { $0.name == "Death Bear" }) else { return }

        let hasDeathBear = isMateAlreadyUnlocked(deathBear)

        // Show Death Bear between 00:00–02:59 only if not unlocked
        if (0...2).contains(hour), !hasDeathBear {
            print("🎯 Showing Death Bear")
            withAnimation {
                promoMate = deathBear
                showPromo = true
            }
            return
        }

        // Suppress normal mate promos only if user clicked "Don't show again today"
        if lastPromoDate == today {
            print("⛔ Promo suppressed by user choice today")
            return
        }

        // Show normal mate with 1-in-3 chance
        if Int.random(in: 1...3) == 1 {
            let eligibleMates = mates.filter { $0.name != "Mocha" && $0.name != "Death Bear" }
            if let randomMate = eligibleMates.randomElement() {
                print("✅ Showing normal mate: \(randomMate.name)")
                withAnimation {
                    promoMate = randomMate
                    showPromo = true
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 🔁 Dev Reset Promo Button — comment this block when not needed
//            Button("🔁 Reset Promo (Dev)") {
//                lastPromoDate = ""
//                print("🧼 Promo reset for today")
//            }
//            .padding(.top, 50)
//            .padding(.trailing, 20)
//            .zIndex(1)

            NavigationView {
                ZStack(alignment: .topTrailing) {
                    VStack {
                        Spacer()

                        Picker("", selection: $selectedTab) {
                            Text(t("Shop", in: "Mate_screen")).tag(0)
                            Text(t("History", in: "Mate_screen")).tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        if selectedTab == 0 {
                            ScrollView {
                                VStack(spacing: 20) {
                                    Text(t("Mates Shop", in: "Mate_screen"))
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 32))
                                        .fontWeight(.bold)
                                        .foregroundColor(.mint)
                                        .padding(.top, 20)

                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(mates.filter { $0.name != "Death Bear" }) { mate in
                                            MateCard(mate: mate) {
                                                if isMateAlreadyUnlocked(mate) {
                                                    showAlreadyOwnedAlert = true
                                                } else {
                                                    checkFirestoreScore { dbScore in
                                                        if dbScore >= mate.cost {
                                                            selectedMate = mate
                                                            showConfirm = true
                                                        } else {
                                                            showInsufficientPoints = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Group {
                                        if scoreManager.purchasedMates.isEmpty {
                                            Text(t("🧸 You haven’t unlocked any mates yet.", in: "Mate_screen"))
                                                .foregroundColor(.gray)
                                                .padding(.top, 30)
                                        }
                                    }
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                    .foregroundColor(.blue)
                                    .padding(.bottom, 20)
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                                Color.clear.frame(height: 80)
                            }
                        } else {
                            VStack(spacing: 20) {
                                Text(t("Unlocked Mates", in: "Mate_screen"))
                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 34))
                                    .fontWeight(.bold)
                                    .foregroundColor(.mint)
                                    .padding(.top)

                                if scoreManager.purchasedMates.isEmpty {
                                    Text(t("🧸 You haven’t unlocked any mates yet.", in: "Mate_screen"))
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    List(scoreManager.purchasedMates) { mate in
                                        HStack(spacing: 15) {
                                            KFImage(mate.imageUrl)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                            VStack(alignment: .leading) {
                                                Text(mate.name)
                                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                                                Text("-\(mate.cost) \(t("Coins", in: "Mate_screen"))")
                                                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                                                    .foregroundColor(.red)
                                            }

                                            Spacer()
                                        }
                                    }
                                    .listStyle(PlainListStyle())
                                    Color.clear.frame(height: 60)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .background(Color(.systemBackground).ignoresSafeArea())
                }
                .alert(t("Unlock Mate?", in: "Mate_screen"), isPresented: $showConfirm, actions: {
                    Button(t("Unlock", in: "Mate_screen"), role: .destructive) {
                        if let mate = selectedMate {
                            if isMateAlreadyUnlocked(mate) {
                                showAlreadyOwnedAlert = true
                            } else {
                                scoreManager.purchaseMate(mate) { success in
                                    if success {
                                        saveMateToFirestore(mate: mate)
                                        scoreManager.purchasedMates.append(mate)
                                        purchasedMateIDs.insert(mate.id)
                                        saveMates()
                                    } else {
                                        showInsufficientPoints = true
                                    }
                                }
                            }
                        }
                    }
                    Button(t("Cancel", in: "Mate_screen"), role: .cancel) {}
                }, message: {
                    Text(
                        String(
                            format: t("Do you want to unlock %@ for %d coins?", in: "Mate_screen"),
                            selectedMate?.name ?? "",
                            selectedMate?.cost ?? 0
                        )
                    )
                })
                .alert(t("Insufficient Coins", in: "Mate_screen"), isPresented: $showInsufficientPoints, actions: {
                    Button(t("OK", in: "Mate_screen"), role: .cancel) {}
                }, message: {
                    Text(t("You don’t have enough coins to unlock this mate.", in: "Mate_screen"))
                })
                .alert(t("Already Unlocked", in: "Mate_screen"), isPresented: $showAlreadyOwnedAlert, actions: {
                    Button(t("OK", in: "Mate_screen"), role: .cancel) {}
                }, message: {
                    Text(t("You already have this mate. You can’t buy it again.", in: "Mate_screen"))
                })
                .onAppear {
                    loadMates()
                    fetchUnlockedMatesFromFirestore()
                }
            }
            .overlay(
                Group {
                    if showPromo, let mate = promoMate {
                        ZStack {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .transition(.opacity)

                            ZStack(alignment: .topTrailing) {
                                VStack(spacing: 8) {
                                    KFImage(mate.imageUrl)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)

                                    Text(t("Meet your next friend", in: "Mate_screen"))
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 18))
                                        .padding(.top, 2)

                                    Text("\(mate.name) Mate")
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                        .padding(.top, 0)

                                    Text("\(mate.cost) \(t("Coins", in: "Mate_screen"))")
                                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 16))
                                        .foregroundColor(.red)
                                        .padding(.top, 2)

                                    if mate.name == "Death Bear" {
                                        Button(action: {
                                            withAnimation {
                                                if !isMateAlreadyUnlocked(mate) {
                                                    scoreManager.purchasedMates.append(mate)
                                                    purchasedMateIDs.insert(mate.id)
                                                    saveMateToFirestore(mate: mate)
                                                    saveMates()
                                                }
                                                showPromo = false
                                            }
                                        }) {
                                            Text(t("Unlock", in: "Mate_screen"))
                                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 14))
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 20)
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        .padding(.top, 10)
                                    } else {
                                        Button(action: {
                                            withAnimation {
                                                let formatter = DateFormatter()
                                                formatter.dateFormat = "yyyy-MM-dd"
                                                lastPromoDate = formatter.string(from: Date())
                                                showPromo = false
                                            }
                                        }) {
                                            Text(t("Don’t show again today", in: "Mate_screen"))
                                                .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 13))
                                                .underline()
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.top, 10)
                                    }
                                }
                                .frame(width: 260)
                                .padding(.vertical, 20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .transition(.scale)
                                .animation(.spring(), value: showPromo)

                                Button(action: {
                                    withAnimation {
                                        showPromo = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                        .frame(width: 30, height: 30)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            )
        }
    }

    private func isMateAlreadyUnlocked(_ mate: Mate) -> Bool {
        let result = scoreManager.purchasedMates.contains { $0.name == mate.name }
        print("🔍 Checking if '\(mate.name)' is unlocked: \(result)")
        return result
    }

    private func saveMateToFirestore(mate: Mate) {
        guard !currentUserId.isEmpty else { return }
        let docRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .collection("mates")
            .document(mate.name)

        docRef.setData(["unlocked": true], merge: true)
    }

    private func saveMates() {
        if let data = try? JSONEncoder().encode(scoreManager.purchasedMates) {
            purchasedMatesData = data
            purchasedMateIDs = Set(scoreManager.purchasedMates.map { $0.id })
        }
    }

    private func loadMates() {
        if let loaded = try? JSONDecoder().decode([Mate].self, from: purchasedMatesData) {
            scoreManager.purchasedMates = loaded
            purchasedMateIDs = Set(loaded.map { $0.id })
        }
    }

    private func fetchUnlockedMatesFromFirestore() {
        guard !currentUserId.isEmpty else { return }

        let userMatesRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .collection("mates")

        userMatesRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching mates: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            let unlockedNames = documents
                .filter { ($0.data()["unlocked"] as? Bool) == true }
                .map { $0.documentID }

            let unlockedMates = mates.filter { unlockedNames.contains($0.name) }

            DispatchQueue.main.async {
                scoreManager.purchasedMates = unlockedMates
                purchasedMateIDs = Set(unlockedMates.map { $0.id })
                saveMates()
                maybeShowPromo()
            }
        }
    }

    private func checkFirestoreScore(completion: @escaping (Int) -> Void) {
        guard !currentUserId.isEmpty else {
            completion(0)
            return
        }

        Firestore.firestore().collection("users").document(currentUserId).getDocument { doc, _ in
            let score = doc?.data()?["score"] as? Int ?? 0
            completion(score)
        }
    }
}

// MARK: - MateCard
struct MateCard: View {
    let mate: Mate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                KFImage(mate.imageUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)

                Text(mate.name)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                Text("\(mate.cost) \(t("Coins", in: "Mate_screen"))")
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 178/255, green: 255/255, blue: 237/255))
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ObservedObject var language = Language.shared
}

struct MatesView_Previews: PreviewProvider {
    static var previews: some View {
        MatesView()
            .environmentObject(ScoreManager.shared)
    }
}
