//
//  SettingView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 26/1/2568 BE.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isShowing: Bool
    @State private var showLanguageView = false
    @State private var showSleepScheduleView = false
    @ObservedObject var language = Language.shared

    let pdfURL = URL(string: "https://drive.google.com/drive/folders/1mvRi0p2DaLxE_LmAiD70kpMxLoWX1wLl?usp=sharing")!

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Title และปุ่มปิด
                HStack {
                    Text(t("Settings", in: "Setting_screen"))
                        .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 1)) {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                // ปุ่มเปลี่ยนภาษา
                settingButton(icon: "globe", title: t("Language", in: "Setting_screen")) {
                    withAnimation {
                        showLanguageView = true
                    }
                }

                // ปุ่มแจ้งเตือนน้ำ
                settingButton(icon: "bell", title: t("Water Notification", in: "Setting_screen")) {
                    withAnimation {
                        showSleepScheduleView = true
                    }
                }
                .fullScreenCover(isPresented: $showSleepScheduleView) {
                    SleepScheduleView()
                }

                // ปุ่มเปิดไฟล์ PDF
                Button(action: {
                    UIApplication.shared.open(pdfURL)
                }) {
                    HStack {
                        Image(systemName: "book")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text(t("How to use", in: "Setting_screen"))
                            .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0)
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 1), value: isShowing)

            if showLanguageView {
                SwitchLang(isShowing: $showLanguageView)
            }
        }
    }

    // ปุ่ม Setting
    func settingButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.custom(language.currentLanguage == "th" ? "Kanit-Regular" : "RobotoCondensed-Regular", size: 17))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var isShowingSettings = true
    return SettingsView(isShowing: $isShowingSettings)
        .preferredColorScheme(.dark)
}
