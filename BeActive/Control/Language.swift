//
//  Language.swift
//  BeActive
//
//  Created by Kasin Thappawan on 23/1/2568 BE.
//

import SwiftUI

class Language: ObservableObject {
    static let shared = Language()

    @Published private(set) var currentLanguage: String = "th"
    private var translations: [String: [String: [String: String]]] = [:]

    init() {
        loadTranslations()
        currentLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "th"
    }

    func loadTranslations() {
        if let url = Bundle.main.url(forResource: "translations", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: [String: String]]] {
            translations = json
        } else {
            print("⚠️ Failed to load translations.json")
            translations = [:]
        }
    }

    func setLanguage(_ language: String) {
        guard translations[language] != nil else {
            print("⚠️ Language \(language) is not available.")
            return
        }
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "AppLanguage")
        objectWillChange.send() // แจ้งให้ SwiftUI อัปเดต UI
    }

    func translate(_ key: String, in screen: String) -> String? {
        return translations[currentLanguage]?[screen]?[key]
    }
}

func t(_ key: String, in screen: String? = nil) -> String {
    if let screen = screen, let translated = Language.shared.translate(key, in: screen) {
        return translated
    }
    return Language.shared.translate(key, in: "default") ?? key
}
