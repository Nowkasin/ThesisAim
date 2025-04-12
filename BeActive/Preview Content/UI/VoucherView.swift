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
                    Text("\(voucher.cost) Coins").font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
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
        Voucher(title: "Discount: ฿20", clinic: "SWU Physical Therapy", cost: 3, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=1")!, code: "DEMO-1111-2222-3333"),
        Voucher(title: "Discount: ฿30", clinic: "ABC Clinic", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=2")!, code: "CODE-AAAA-BBBB-CCCC"),
        Voucher(title: "Discount: ฿40", clinic: "XYZ Physical Center", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=3")!, code: "PROMO-1234-5678-9012"),
        Voucher(title: "Discount: ฿50", clinic: "EF Clinic", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=4")!, code: "VIP-4455-6677-8899"),
        Voucher(title: "1 Free Treatment", clinic: "GH Clinic", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=5")!, code: "FREE-0000-0000-0000"),
        Voucher(title: "Discount: ฿60", clinic: "Lightcare Physical Center", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=6")!, code: "SALE-9999-8888-7777")
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
                    Text("Shop").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if selectedTab == 0 {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Voucher Shop")
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
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("Voucher History").font(.largeTitle).padding(.top)

                        if scoreManager.purchasedVouchers.isEmpty {
                            Text("🛒 Voucher has not been purchased yet")
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
                                                    Text("Code: \(code)").font(.caption2).foregroundColor(.green)
                                                }
                                                if voucher.isActivated {
                                                    Text("✅ Activated").font(.caption2).foregroundColor(.blue)
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
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            if let index = scoreManager.purchasedVouchers.firstIndex(of: voucher) {
                                                scoreManager.purchasedVouchers[index].isActivated.toggle()
                                                saveVouchers()
                                            }
                                        } label: {
                                            Label(voucher.isActivated ? "Deactivate" : "Activate", systemImage: "checkmark.circle")
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
            .alert("Confirm Voucher Redemption?", isPresented: $showConfirm, actions: {
                Button("Redeem Now", role: .destructive) {
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
                Button("Cancel", role: .cancel) {
                    selectedVoucher = nil
                }
            }, message: {
                Text("Do you want to redeem \"\(selectedVoucher?.title ?? "")\"?")
            })
            .alert("Insufficient Coins", isPresented: $showInsufficientPoints) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You don’t have enough coins to redeem this voucher.")
            }
            .alert("Voucher Code", isPresented: $showCodePopup) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(selectedVoucher?.code ?? "Code not found")
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

