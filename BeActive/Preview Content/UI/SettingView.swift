//
//  SettingView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 26/1/2568 BE.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var themeManager = ThemeManager()
    @Binding var isShowing: Bool
    @State private var showLanguageView = false
    @State private var showSleepScheduleView = false // ✅ ใช้เปิดหน้า SleepScheduleView

    // ✅ อัปเดตลิงก์ Google Drive (ต้องเป็นไฟล์ที่แชร์สาธารณะ)
    let pdfURL = URL(string: "https://drive.google.com/drive/u/0/my-drive")!

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title และปุ่มปิด
                HStack {
                    Text(t("Settings", in: "Setting_screen"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 1)) {
                            isShowing = false // ปิด SettingsView
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(themeManager.textColor)
                    }
                }
                .padding()
                
                // ✅ ปุ่มเปลี่ยนภาษา
                settingButton(icon: "globe", title: t("Language", in: "Setting_screen")) {
                    withAnimation {
                        showLanguageView = true
                    }
                }
                
                // ✅ ปุ่มแจ้งเตือนน้ำ (Water Notification)
                settingButton(icon: "bell", title: t("Water Notification", in: "Setting_screen")) {
                    withAnimation {
                        showSleepScheduleView = true // ✅ เปิดหน้า SleepScheduleView
                    }
                }
                .fullScreenCover(isPresented: $showSleepScheduleView) {
                    SleepScheduleView() // ✅ เปิดแบบเต็มจอ
                }
                
                Spacer() // ✅ เพิ่ม Spacer เพื่อให้ปุ่ม book อยู่ล่างสุด

                // ✅ ปุ่มเปิดไฟล์ PDF (อยู่ล่างสุด)
                settingButton(icon: "book", title: t("How to use", in: "Setting_screen")) {
                    UIApplication.shared.open(pdfURL)
                }
                .padding(.bottom, 20) // ✅ เพิ่ม padding เพื่อให้ปุ่มไม่ติดขอบล่าง
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0)
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 1), value: isShowing)
            
            // ✅ แสดงหน้าภาษาแบบ overlay
            if showLanguageView {
                SwitchLang(isShowing: $showLanguageView)
            }
        }
    }

    // ✅ ฟังก์ชันสร้างปุ่ม Setting
    func settingButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(themeManager.textColor)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var isShowingSettings = true
    return SettingsView(isShowing: $isShowingSettings)
}
