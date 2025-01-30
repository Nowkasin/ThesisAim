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
                
                // ปุ่มเปลี่ยนภาษา อยู่ใต้หัวข้อ Settings
                Button(action: {
                    withAnimation {
                        showLanguageView = true // เปิดหน้า UILang
                    }
                }) {
                    Text(t("Language", in: "Setting_screen"))
                        .font(.body)
                        .foregroundColor(themeManager.textColor)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // ชิดซ้าย
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
