//
//  MatesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI
import FirebaseFirestore

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
    @EnvironmentObject var scoreManager: ScoreManager
    @AppStorage("purchasedMatesData") private var purchasedMatesData: Data = Data()
    @AppStorage("currentUserId") private var currentUserId: String = ""

    @State private var selectedMate: Mate? = nil
    @State private var showConfirm = false
    @State private var showInsufficientPoints = false
    @State private var selectedTab = 0

    @State private var purchasedMateIDs: Set<UUID> = []

    let mates: [Mate] = [
        Mate(name: "Mates A", cost: 1, imageUrl: URL(string: "https://yourdomain.com/a.png")!),
        Mate(name: "Mates B", cost: 2, imageUrl: URL(string: "https://yourdomain.com/b.png")!),
        Mate(name: "Mates C", cost: 3, imageUrl: URL(string: "https://yourdomain.com/c.png")!),
        Mate(name: "Mates D", cost: 4, imageUrl: URL(string: "https://yourdomain.com/d.png")!),
        Mate(name: "Mates E", cost: 5, imageUrl: URL(string: "https://yourdomain.com/e.png")!),
        Mate(name: "Mates F", cost: 6, imageUrl: URL(string: "https://yourdomain.com/f.png")!)
    ]

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                VStack {
                    HStack {
                        Spacer()
                        ScoreView()
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                    }

                    Picker("", selection: $selectedTab) {
                        Text("Shop").tag(0)
                        Text("History").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    if selectedTab == 0 {
                        ScrollView {
                            VStack(spacing: 20) {
                                Text("Mates Shop")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(.top, 20)

                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(mates.filter { !purchasedMateIDs.contains($0.id) }) { mate in
                                        MateCard(mate: mate) {
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

                                if purchasedMateIDs.isEmpty {
                                    Text("🧸 You haven’t unlocked any mates yet.")
                                        .foregroundColor(.gray)
                                        .padding(.top, 30)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("Unlocked Mates")
                                .font(.largeTitle)
                                .padding(.top)

                            if scoreManager.purchasedMates.isEmpty {
                                Text("🧸 You haven’t unlocked any mates yet.")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                List(scoreManager.purchasedMates) { mate in
                                    HStack(spacing: 15) {
                                        AsyncImage(url: mate.imageUrl) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable().scaledToFill()
                                            case .failure:
                                                Image(systemName: "photo")
                                            default:
                                                Color.gray.opacity(0.2)
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                        VStack(alignment: .leading) {
                                            Text(mate.name)
                                                .font(.headline)
                                            Text("-\(mate.cost) Coins")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }

                                        Spacer()
                                    }
                                }
                                .listStyle(PlainListStyle())
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color(.systemBackground).ignoresSafeArea())
            }
            .alert("Unlock Mate?", isPresented: $showConfirm, actions: {
                Button("Unlock", role: .destructive) {
                    if let mate = selectedMate {
                        scoreManager.purchaseMate(mate) { success in
                            if success {
                                if !scoreManager.purchasedMates.contains(mate) {
                                    scoreManager.purchasedMates.append(mate)
                                    purchasedMateIDs.insert(mate.id)
                                    saveMates()
                                }
                            } else {
                                showInsufficientPoints = true
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Do you want to unlock \"\(selectedMate?.name ?? "")\" for \(selectedMate?.cost ?? 0) coins?")
            })
            .alert("Insufficient Coins", isPresented: $showInsufficientPoints, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("You don’t have enough coins to unlock this mate.")
            })
            .onAppear {
                loadMates()
            }
        }
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
                AsyncImage(url: mate.imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .cornerRadius(15)

                Text(mate.name)
                    .font(.headline)
                    .foregroundColor(.black)

                Text("\(mate.cost) Coins")
                    .font(.subheadline)
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
}

struct MatesView_Previews: PreviewProvider {
    static var previews: some View {
        MatesView()
            .environmentObject(ScoreManager.shared)
    }
}
