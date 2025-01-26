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
    
    var body: some View {
        ZStack {
            Color.white
                .shadow(radius: 5)
                .edgesIgnoringSafeArea(.vertical)
            
            VStack {
                HStack {
                    Text(t("Settings", in: "Setting_screen"))
                        .font(.title)
                        .fontWeight(.bold)
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
                
                Spacer()
                Text("Settings Content")
                    .font(.body)
                    .foregroundColor(.gray)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0) // ใช้ opacity เพื่อให้มีการแอนิเมชัน
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height) // ใช้ offset เพื่อให้แอนิเมชันเลื่อน
            .animation(.easeInOut(duration: 1), value: isShowing) // เพิ่ม animation เมื่อ isShowing เปลี่ยนแปลง
        }
    }
}

#Preview {
    @Previewable @State var isShowingSettings = true
    return SettingsView(isShowing: $isShowingSettings)
}
