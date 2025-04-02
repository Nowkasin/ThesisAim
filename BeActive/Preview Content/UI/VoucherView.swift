//
//  VoucherView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI

struct Voucher: Identifiable {
    let id = UUID()
    let title: String
    let clinic: String
    let cost: Int
    let imageUrl: URL
}

struct VoucherView: View {
    let vouchers: [Voucher] = [
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v1.png")!),
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v2.png")!),
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v3.png")!),
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v4.png")!),
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v5.png")!),
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v6.png")!),
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 3, imageUrl: URL(string: "https://yourdomain.com/v7.png")!)
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
                Text("Voucher Shop")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 40/255, green: 54/255, blue: 85/255))
                    .padding(.top, 40)

                ForEach(vouchers) { voucher in
                    VoucherCard(voucher: voucher) {
                        print("Tapped: \(voucher.title)")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct VoucherCard: View {
    let voucher: Voucher
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                AsyncImage(url: voucher.imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(voucher.title)
                        .font(.headline)
                        .foregroundColor(Color(red: 40/255, green: 54/255, blue: 85/255))

                    Text(voucher.clinic)
                        .font(.subheadline)
                        .foregroundColor(Color.blue)

                    Text("\(voucher.cost) Coins")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 40/255, green: 54/255, blue: 85/255))
                }

                Spacer()
            }
            .padding()
            .background(Color(red: 255/255, green: 182/255, blue: 182/255)) // pink
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VoucherView_Previews: PreviewProvider {
    static var previews: some View {
        VoucherView()
    }
}

