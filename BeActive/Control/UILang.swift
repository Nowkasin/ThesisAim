//
//  UILang.swift
//  BeActive
//
//  Created by Kasin Thappawan on 27/1/2568 BE.
//

import SwiftUI

struct UILang: View {
    @Binding var isShowing: Bool // ใช้ Binding เพื่อควบคุมการแสดงผล
    @ObservedObject var language = Language.shared // เชื่อมต่อกับ Singleton

    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.vertical)
                .shadow(radius: 5)
            
            VStack {
                HStack {
                    Text(t("Select Language", in: "Language_screen"))
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 1)) {
                            isShowing = false // ปิดหน้า UILang
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                
                Spacer()
                
                // ปุ่มเปลี่ยนเป็นภาษาไทย
                Button(action: {
                    language.setLanguage("th")
                    isShowing = false // ปิดหน้าภาษาเมื่อเลือก
                }) {
                    Text("ภาษาไทย")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(language.currentLanguage == "th" ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .padding()
                
                // ปุ่มเปลี่ยนเป็นภาษาอังกฤษ
                Button(action: {
                    language.setLanguage("en")
                    isShowing = false // ปิดหน้าภาษาเมื่อเลือก
                }) {
                    Text("English")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(language.currentLanguage == "en" ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0) // ใช้ opacity เพื่อการแอนิเมชัน
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height) // ใช้ offset เพื่อเลื่อนจากด้านล่าง
            .animation(.easeInOut(duration: 1), value: isShowing) // แอนิเมชันเมื่อ isShowing เปลี่ยน
        }
    }
}

#Preview {
    @Previewable @State var isShowingLanguageView = true
    return UILang(isShowing: $isShowingLanguageView)
}
