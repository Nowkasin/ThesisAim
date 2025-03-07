//
//  DeviceHelper.swift
//  BeActive
//
//  Created by Kasin Thappawan on 28/2/2568 BE.
//

import SwiftUI

struct DeviceHelper {
    /// ตรวจสอบว่าเป็น iPad หรือ Mac Catalyst
    static var isTablet: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return UIDevice.current.userInterfaceIdiom == .pad
        #endif
    }
    
    /// ตรวจสอบว่าเป็น iPad Mini (โดยดูจากความสูงของ nativeBounds)
    static var isIPadMini: Bool {
        return isTablet && UIScreen.main.nativeBounds.height < 2266 // iPad Mini (6th Gen)
    }
    
    /// ตรวจสอบว่าเป็นแนวนอนหรือแนวตั้ง
    static var isLandscape: Bool {
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }

    /// ดึงขนาดหน้าจอปัจจุบัน
    static func getCurrentScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    /// ปรับระยะห่างให้เหมาะกับอุปกรณ์ (ใช้กับ .padding())
    static func adaptivePadding() -> CGFloat {
        if isTablet {
            return isIPadMini ? 30 : 40 // iPad Mini ใช้ค่าที่เล็กลง
        } else {
            return 20
        }
    }

    /// ปรับขนาดฟอนต์อัตโนมัติ (ใช้กับ .font(.system(size:)))
    static func adaptiveFontSize(baseSize: CGFloat) -> CGFloat {
        if isTablet {
            return isIPadMini ? baseSize * 1.15 : baseSize * 1.3
        } else {
            return baseSize
        }
    }
    
    /// ปรับขนาดเฟรมให้เหมาะกับอุปกรณ์ (ใช้กับ .frame())
    static func adaptiveFrameSize(baseSize: CGFloat) -> CGFloat {
        return isTablet ? (isIPadMini ? baseSize * 1.1 : baseSize * 1.2) : baseSize
    }
    
    /// ปรับระยะห่างแนวตั้งให้เหมาะกับอุปกรณ์ (ใช้กับ Spacer().frame(height:))
    static func adaptiveSpacing(baseSpacing: CGFloat) -> CGFloat {
        return isTablet ? (isIPadMini ? baseSpacing * 1.3 : baseSpacing * 1.5) : baseSpacing
    }
    
    /// ปรับขนาด corner radius สำหรับ UI (ใช้กับ .cornerRadius())
    static func adaptiveCornerRadius(baseRadius: CGFloat) -> CGFloat {
        return isTablet ? (isIPadMini ? baseRadius * 1.15 : baseRadius * 1.3) : baseRadius
    }
}
