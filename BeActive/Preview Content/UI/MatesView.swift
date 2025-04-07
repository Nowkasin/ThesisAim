//
//  MatesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI

struct Mate: Identifiable {
    let id = UUID()
    let name: String
    let cost: Int
    let imageUrl: URL
}

struct MatesView: View {
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

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Mates Shop")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 40)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(mates) { mate in
                        MateCard(mate: mate) {
                            print("Tapped \(mate.name)")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

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
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }

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
            .preferredColorScheme(.light) // ลองแสดงใน Light Mode
        MatesView()
            .preferredColorScheme(.dark)  // ลองแสดงใน Dark Mode
    }
}
