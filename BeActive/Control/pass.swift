//
//  pass.swift
//  BeActive
//
//  Created by Kasin Thappawan on 12/1/2568 BE.
//

import Foundation

class PasswordValidator {
    var errorMessage: String = ""

    @discardableResult
    func validatePassword(_ password: String) -> Bool {
        errorMessage = ""

        // Check for minimum length
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }

        // Check for at least one uppercase letter
        if !password.contains(where: { $0.isUppercase }) {
            errorMessage = "Password must contain at least one uppercase letter."
            return false
        }

        // Check for at least one lowercase letter
        if !password.contains(where: { $0.isLowercase }) {
            errorMessage = "Password must contain at least one lowercase letter."
            return false
        }

        // Check for at least one digit
        if !password.contains(where: { $0.isNumber }) {
            errorMessage = "Password must contain at least one digit."
            return false
        }

        // Check for at least one special character
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:'\",.<>?/\\")
        if password.rangeOfCharacter(from: specialCharacterSet) == nil {
            errorMessage = "Password must contain at least one special character."
            return false
        }

        return true
    }
}

