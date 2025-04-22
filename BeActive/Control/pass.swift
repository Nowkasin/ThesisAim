//
//  pass.swift
//  BeActive
//
//  Created by Kasin Thappawan on 12/1/2568 BE.
//

import Foundation
// แปลด้วย พน.
class PasswordValidator {
    var errorMessage: String = ""

    @discardableResult
    func validatePassword(_ password: String) -> Bool {
        errorMessage = ""

        // Check for minimum length
        if password.count < 6 {
            errorMessage = t("min_length", in: "Password")
            return false
        }

        // Check for at least one uppercase letter
        if !password.contains(where: { $0.isUppercase }) {
            errorMessage = t("uppercase", in: "Password")
            return false
        }

        // Check for at least one lowercase letter
        if !password.contains(where: { $0.isLowercase }) {
            errorMessage = t("lowercase", in: "Password")
            return false
        }

        // Check for at least one digit
        if !password.contains(where: { $0.isNumber }) {
            errorMessage = t("number", in: "Password")
            return false
        }

        // Check for at least one special character
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:'\",.<>?/\\")
        if password.rangeOfCharacter(from: specialCharacterSet) == nil {
            errorMessage = t("special", in: "Password")
            return false
        }

        return true
    }
}
