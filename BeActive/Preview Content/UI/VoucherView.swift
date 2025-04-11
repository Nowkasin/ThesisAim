//
//  VoucherView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI

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

// MARK: - VoucherCard View
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
                        .foregroundColor(.blue)

                    Text("\(voucher.cost) Coins")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 40/255, green: 54/255, blue: 85/255))
                }

                Spacer()
            }
            .padding()
            .background(Color(red: 255/255, green: 182/255, blue: 182/255))
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - VoucherView
struct VoucherView: View {
    @EnvironmentObject var scoreManager: ScoreManager

    @AppStorage("purchasedVouchersData") private var purchasedVouchersData: Data = Data()
    @State private var selectedTab = 0
    @State private var showConfirm = false
    @State private var selectedVoucher: Voucher? = nil
    @State private var showCodePopup = false

    let vouchers: [Voucher] = [
        Voucher(title: "ส่วนลด 20 บาท", clinic: "คลินิกกายภาพ มศว", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=1")!, code: "DEMO-1111-2222-3333"),
        Voucher(title: "ส่วนลด 30 บาท", clinic: "คลินิก ABC", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=2")!, code: "CODE-AAAA-BBBB-CCCC"),
        Voucher(title: "ส่วนลด 40 บาท", clinic: "ศูนย์กายภาพ XYZ", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=3")!, code: "PROMO-1234-5678-9012"),
        Voucher(title: "ลดค่ารักษา 50 บาท", clinic: "คลินิก EF", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=4")!, code: "VIP-4455-6677-8899"),
        Voucher(title: "บำบัดฟรี 1 ครั้ง", clinic: "คลินิก GH", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=5")!, code: "FREE-0000-0000-0000"),
        Voucher(title: "ลด 60 บาท", clinic: "กายภาพ LightCare", cost: 0, imageUrl: URL(string: "https://via.placeholder.com/100x80?text=6")!, code: "SALE-9999-8888-7777")
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                VStack {
                    HStack {
                        Spacer()
                        ScoreView()
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)

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
                                    .foregroundColor(Color(red: 255/255, green: 182/255, blue: 182/255))
                                    .padding(.top, 20)

                                ForEach(vouchers) { voucher in
                                    if !scoreManager.purchasedVouchers.contains(where: { $0.id == voucher.id }) {
                                        VoucherCard(voucher: voucher) {
                                            selectedVoucher = voucher
                                            showConfirm = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    } else {
                        VStack(spacing: 15) {
                            Text("Voucher History")
                                .font(.largeTitle)
                                .padding(.top)

                            if scoreManager.purchasedVouchers.isEmpty {
                                Text("🛒 ยังไม่มีการซื้อ Voucher")
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
                                                    case .success(let image):
                                                        image.resizable().scaledToFill()
                                                    case .failure:
                                                        Image(systemName: "photo")
                                                    default:
                                                        Color.gray.opacity(0.2)
                                                    }
                                                }
                                                .frame(width: 50, height: 40)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                                VStack(alignment: .leading) {
                                                    Text(voucher.title)
                                                    Text(voucher.clinic)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    if let code = voucher.code {
                                                        Text("Code: \(code)")
                                                            .font(.caption2)
                                                            .foregroundColor(.green)
                                                    }
                                                    if voucher.isActivated {
                                                        Text("✅ Activated")
                                                            .font(.caption2)
                                                            .foregroundColor(.blue)
                                                    }
                                                }

                                                Spacer()
                                                Text("-\(voucher.cost)")
                                                    .foregroundColor(.red)
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
                                                Label(scoreManager.purchasedVouchers.first(where: { $0.id == voucher.id })?.isActivated == true ? "Deactivate" : "Activate", systemImage: "checkmark.circle")
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
                .background(Color(.systemBackground).ignoresSafeArea())
            }
            .alert("ยืนยันการรับ Voucher?", isPresented: $showConfirm, actions: {
                Button("รับเลย", role: .destructive) {
                    if let voucher = selectedVoucher {
                        _ = scoreManager.purchaseVoucher(voucher)
                        saveVouchers()
                    }
                }
                Button("ยกเลิก", role: .cancel) {}
            }, message: {
                Text("คุณต้องการรับ \"\(selectedVoucher?.title ?? "")\" ใช่ไหม?")
            })
            .alert("Voucher Code", isPresented: $showCodePopup, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(selectedVoucher?.code ?? "ไม่พบรหัส")
            })
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
}

// MARK: - String Extension
extension StringProtocol {
    func chunked(_ size: Int, separator: Character = "-") -> String {
        return stride(from: 0, to: self.count, by: size).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }.joined(separator: String(separator))
    }
}



struct VoucherView_Previews: PreviewProvider {
    static var previews: some View {
        VoucherView()
            .environmentObject(ScoreManager.shared)
    }
}

