//
//  AppDelegate.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/3/2568 BE.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    /// ✅ ล็อกหน้าจอให้เป็นแนวตั้งตลอด (ทั้ง iPhone และ iPad)
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
