//
//  Language.swift
//  BeActive
//
//  Created by Kasin Thappawan on 23/1/2568 BE.
//

import SwiftUI

class Language: ObservableObject {
    static let shared = Language()
    
    @Published private(set) var currentLanguage: String = "en"
    private var translations: [String: Any] = [:]
    
    init() {
        loadTranslations()
        currentLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "th"
    }
    
    func loadTranslations() {
        if let url = Bundle.main.url(forResource: "translations", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
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
        objectWillChange.send()
    }
    
    /// NEW: Supports nested dot-separated paths like `"Noti_Screen.WaterNoti.title"`
    func translate(_ key: String, in screen: String) -> String? {
        let screenComponents = screen.components(separatedBy: ".")
        guard let langDict = translations[currentLanguage] as? [String: Any] else { return nil }
        
        var current: Any? = langDict
        for part in screenComponents {
            if let dict = current as? [String: Any] {
                current = dict[part]
            } else {
                return nil
            }
        }
        
        // ถ้า current เป็น dictionary -> หา key ใน dict นี้
        if let dict = current as? [String: Any], let result = dict[key] as? String {
            return result
        }
        
        return nil
    }
}

    func t(_ key: String, in screen: String? = nil) -> String {
        if let screen = screen {
            return Language.shared.translate(key, in: screen) ?? key
        }
        return Language.shared.translate(key, in: "default") ?? key
    }
