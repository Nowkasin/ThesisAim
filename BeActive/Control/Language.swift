//
//  Language.swift
//  BeActive
//
//  Created by Kasin Thappawan on 23/1/2568 BE.
//

import Foundation

class Language {
    static let shared = Language() // Singleton instance

    private(set) var currentLanguage: String = "th" // Default language
    private var translations: [String: [String: [String: String]]] = [:]

    init() {
        loadTranslations()
    }

    func loadTranslations() {
        if let url = Bundle.main.url(forResource: "translations", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: [String: String]]] {
            translations = json
        } else {
            print("Failed to load translations.json")
        }
    }

    func setLanguage(_ language: String) {
        guard translations[language] != nil else {
            print("Language \(language) is not available.")
            return
        }
        currentLanguage = language
    }

    func translate(_ key: String, in screen: String) -> String {
        return translations[currentLanguage]?[screen]?[key] ?? key
    }
}

// Global translation function
func t(_ key: String, in screen: String) -> String {
    return Language.shared.translate(key, in: screen)
}
