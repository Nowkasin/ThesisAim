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
    @State private var showMessageView = false // เพิ่ม State สำหรับ MessageView

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
                
                // ปุ่มเปลี่ยนภาษา
                Button(action: {
                    withAnimation {
                        showLanguageView = true
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title2)
                            .foregroundColor(themeManager.textColor)
                        
                        Text(t("Language", in: "Setting_screen"))
                            .font(.body)
                            .foregroundColor(themeManager.textColor)
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    .padding(.horizontal)
                }
                
                // ✅ ปุ่มเปิดไฟล์ PDF ที่ถูกต้อง
                Button(action: {
                    UIApplication.shared.open(pdfURL)
                }) {
                    HStack {
                        Image(systemName: "book")
                            .font(.title2)
                            .foregroundColor(themeManager.textColor)
                        
                        Text(t("How to use", in: "Setting_screen"))
                            .font(.body)
                            .foregroundColor(themeManager.textColor)
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0)
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 1), value: isShowing)
            
            // แสดง UILang ซ้อนกัน
            if showLanguageView {
                SwitchLang(isShowing: $showLanguageView)
            }
        }
    }
}

#Preview {
    @Previewable @State var isShowingSettings = true
    return SettingsView(isShowing: $isShowingSettings)
}

