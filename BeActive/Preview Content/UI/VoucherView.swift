//
//  VoucherView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Voucher Model
struct Voucher: Identifiable, Equatable, Codable {
    let id: UUID
    let title: String
    let clinic: String
    let cost: Int
    let imageUrl: URL
    var code: String? = nil
    var isActivated: Bool = false

    init(id: UUID = UUID(), title: String, clinic: String, cost: Int, imageUrl: URL, code: String? = nil, isActivated: Bool = false) {
        self.id = id
        self.title = title
        self.clinic = clinic
        self.cost = cost
        self.imageUrl = imageUrl
        self.code = code
        self.isActivated = isActivated
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
                        image.resizable().scaledToFill()
                    case .failure:
                        Image(systemName: "photo").resizable().scaledToFit().foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(voucher.title).font(.headline).foregroundColor(.primary)
                    Text(voucher.clinic).font(.subheadline).foregroundColor(.blue)
                    Text(String(format: t("cost_format", in: "Voucher_screen"), voucher.cost))
.font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                }
                Spacer()
            }
            .padding()
            .background(Color(red: 1, green: 0.71, blue: 0.71))
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - VoucherView
struct VoucherView: View {
    @EnvironmentObject var scoreManager: ScoreManager
    @AppStorage("purchasedVouchersData") private var purchasedVouchersData: Data = Data()
    @AppStorage("currentUserId") private var currentUserId: String = ""

    @State private var selectedTab = 0
    @State private var showConfirm = false
    @State private var showInsufficientPoints = false
    @State private var selectedVoucher: Voucher? = nil
    @State private var showCodePopup = false

    let vouchers: [Voucher] = [
        Voucher(title: "\(t("Discount", in: "Voucher_screen.Coupon")): ฿20", clinic: t("SWU Physical Therapy", in: "Voucher_screen.Clinic"), cost: 1000, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=1")!, code: "DEMO-1111-2222-3333"),
        Voucher(title: "\(t("Discount", in: "Voucher_screen.Coupon")): ฿30", clinic: t("ABC Clinic", in: "Voucher_screen.Clinic"), cost: 1000, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=2")!, code: "CODE-AAAA-BBBB-CCCC"),
        Voucher(title: "\(t("Discount", in: "Voucher_screen.Coupon")): ฿40", clinic: t("XYZ Physical Center", in: "Voucher_screen.Clinic"), cost: 2000, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=3")!, code: "PROMO-1234-5678-9012"),
        Voucher(title: "\(t("Discount", in: "Voucher_screen.Coupon")): ฿50", clinic: t("EF Clinic", in: "Voucher_screen.Clinic"), cost: 2000, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=4")!, code: "VIP-4455-6677-8899"),
        Voucher(title: t("free_treatment", in: "Voucher_screen.Coupon"), clinic: t("GH Clinic", in: "Voucher_screen.Clinic"), cost: 3000, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=5")!, code: "FREE-0000-0000-0000"),
        Voucher(title: "\(t("Discount", in: "Voucher_screen.Coupon")): ฿60", clinic: t("Lightcare Physical Center", in: "Voucher_screen.Clinic"), cost: 3000, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=6")!, code: "SALE-9999-8888-7777")
    ]

    var body: some View {
        NavigationView {
            VStack {
//                HStack {
//                    Spacer()
//                    ScoreView()
//                        .padding(.trailing, 20)
//                        .padding(.top, 10)
//                }
                
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
                            Text(t("Voucher Shop", in: "Voucher_screen"))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.pink)
                                .padding(.top, 20)

                            ForEach(vouchers) { voucher in
                                if !scoreManager.purchasedVouchers.contains(where: { $0.id == voucher.id }) {
                                    VoucherCard(voucher: voucher) {
                                        checkFirestoreScore { dbScore in
                                            if dbScore >= voucher.cost {
                                                selectedVoucher = voucher
                                                showConfirm = true
                                            } else {
                                                showInsufficientPoints = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        Color.clear.frame(height: 80)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text(t("Voucher History", in: "Voucher_screen")).font(.largeTitle).padding(.top)

                        if scoreManager.purchasedVouchers.isEmpty {
                            Text(t("🛒 Voucher has not been purchased yet", in: "Voucher_screen"))
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            List {
                                ForEach(scoreManager.purchasedVouchers) { voucher in
                                    Button {
                                        selectedVoucher = voucher
                                        showCodePopup = true
                                    } label: {
                                        HStack {
                                            AsyncImage(url: voucher.imageUrl) { phase in
                                                switch phase {
                                                case .success(let image): image.resizable().scaledToFill()
                                                case .failure: Image(systemName: "photo")
                                                default: Color.gray.opacity(0.2)
                                                }
                                            }
                                            .frame(width: 50, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                            VStack(alignment: .leading) {
                                                Text(voucher.title)
                                                Text(voucher.clinic).font(.caption).foregroundColor(.gray)
                                                if let code = voucher.code {
                                                    Text(t("Code", in: "Voucher_screen") + ": \(code)").font(.caption2).foregroundColor(.green)
                                                }
                                                if voucher.isActivated {
                                                    Text(t("Activated", in: "Voucher_screen")).font(.caption2).foregroundColor(.blue)
                                                }
                                            }

                                            Spacer()
                                            Text("-\(voucher.cost)").foregroundColor(.red)
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            if let index = scoreManager.purchasedVouchers.firstIndex(of: voucher) {
                                                scoreManager.purchasedVouchers.remove(at: index)
                                                saveVouchers()
                                            }
                                        } label: {
                                            Label(t("Delete", in: "Pain_screen"), systemImage: "trash")
                                        }

                                        Button {
                                            if let index = scoreManager.purchasedVouchers.firstIndex(of: voucher) {
                                                scoreManager.purchasedVouchers[index].isActivated.toggle()
                                                saveVouchers()
                                            }
                                        } label: {
                                            Label(voucher.isActivated ? t("Deactivate", in: "Voucher_screen") : t("Activate", in: "Voucher_screen"), systemImage: "checkmark.circle")
                                        }
                                        .tint(.blue)
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .alert(t("Confirm Voucher Redemption?", in: "Voucher_screen"), isPresented: $showConfirm, actions: {
                Button(t("Redeem Now", in: "Voucher_screen"), role: .destructive)  {
                    if let voucher = selectedVoucher {
                        scoreManager.purchaseVoucher(voucher) { success in
                            if success {
                                // ✅ Avoid adding duplicate vouchers
                                if !scoreManager.purchasedVouchers.contains(where: { $0.id == voucher.id }) {
                                    scoreManager.purchasedVouchers.append(voucher)
                                    saveVouchers()
                                }
                                // Clear selectedVoucher after purchase to avoid duplication
                                selectedVoucher = nil
                            } else {
                                showInsufficientPoints = true
                            }
                        }
                    }
                }
                Button(t("Cancel", in: "Voucher_screen"), role: .cancel) {
                    selectedVoucher = nil
                }
            },  message: {
                Text(t("Do you want to redeem", in: "Voucher_screen") + " \"\(selectedVoucher?.title ?? "")\"?")
            })
            .alert(t("Insufficient Coins", in: "Voucher_screen"), isPresented: $showInsufficientPoints) {
                Button(t("OK", in: "home_screen"), role: .cancel) {}
            } message: {
                Text(t("You don’t have enough coins to redeem this voucher.", in: "Voucher_screen"))
            }
            .alert(t("Voucher Code", in: "Voucher_screen"), isPresented: $showCodePopup) {
                Button(t("OK", in: "Voucher_screen"), role: .cancel) {}
            } message: {
                Text(selectedVoucher?.code ?? t("Code not found", in: "Voucher_screen"))
            }
            .onAppear(perform: loadVouchers)
        }
    }

    private func saveVouchers() {
        if let data = try? JSONEncoder().encode(scoreManager.purchasedVouchers) {
            purchasedVouchersData = data
        }
    }

    private func loadVouchers() {
        if let loaded = try? JSONDecoder().decode([Voucher].self, from: purchasedVouchersData) {
            scoreManager.purchasedVouchers = loaded
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
struct VoucherView_Previews: PreviewProvider {
    static var previews: some View {
        VoucherView()
            .environmentObject(ScoreManager.shared)
    }
}

