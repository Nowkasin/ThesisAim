//
//  SwitchLang.swift
//  BeActive
//
//  Created by Kasin Thappawan on 30/1/2568 BE.
//

import SwiftUI

struct SwitchLang: View {
    @Binding var isShowing: Bool
    @ObservedObject var language = Language.shared

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.vertical)
                .shadow(radius: 5)

            VStack {
                HStack {
                    Text(t("Select Language", in: "Language_screen"))
                        .font(.system(size: 20))
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

                Spacer()

                Button(action: {
                    language.setLanguage("th")
                    isShowing = false
                }) {
                    Text("ภาษาไทย")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(language.currentLanguage == "th" ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    language.setLanguage("en")
                    isShowing = false
                }) {
                    Text("English")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(language.currentLanguage == "en" ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(isShowing ? 1 : 0)
            .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 1), value: isShowing)
        }
    }
}

#Preview {
    @Previewable @State var isShowingLanguageView = true
    return SwitchLang(isShowing: $isShowingLanguageView)
}
