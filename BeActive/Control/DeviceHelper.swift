//
//  DeviceHelper.swift
//  BeActive
//
//  Created by Kasin Thappawan on 28/2/2568 BE.
//

import SwiftUI

struct DeviceHelper {
    /// ตรวจสอบว่าหน้าจอเป็นขนาดใหญ่ (iPad หรือ Mac Catalyst)
    static var isTablet: Bool {
        return getCurrentScreenWidth() > 600
    }
    
    /// ดึงขนาดหน้าจอปัจจุบัน รองรับการหมุนหน้าจอ
    static func getCurrentScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    /// ปรับระยะห่างให้เหมาะกับอุปกรณ์ (ใช้กับ .padding())
    static func adaptivePadding() -> CGFloat {
        return isTablet ? 40 : 20
    }

    /// ปรับขนาดฟอนต์อัตโนมัติ (ใช้กับ .font(.system(size:)))
    static func adaptiveFontSize(baseSize: CGFloat) -> CGFloat {
        return isTablet ? baseSize * 1.3 : baseSize
    }
    
    /// ปรับขนาดเฟรมให้เหมาะกับอุปกรณ์ (ใช้กับ .frame())
    static func adaptiveFrameSize(baseSize: CGFloat) -> CGFloat {
        return isTablet ? baseSize * 1.2 : baseSize
    }
    
    /// ปรับระยะห่างแนวตั้งให้เหมาะกับอุปกรณ์ (ใช้กับ Spacer().frame(height:))
    static func adaptiveSpacing(baseSpacing: CGFloat) -> CGFloat {
        return isTablet ? baseSpacing * 1.5 : baseSpacing
    }
    
    /// ปรับขนาด corner radius สำหรับ UI (ใช้กับ .cornerRadius())
    static func adaptiveCornerRadius(baseRadius: CGFloat) -> CGFloat {
        return isTablet ? baseRadius * 1.3 : baseRadius
    }
}

/// ใช้ ViewModifier เพื่อตรวจจับการหมุนหน้าจอ
struct DeviceRotationAwareModifier: ViewModifier {
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                updateScreenWidth()
                NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    updateScreenWidth()
                }
            }
    }
    
    private func updateScreenWidth() {
        screenWidth = UIScreen.main.bounds.width
    }
}

/// ใช้งาน ViewModifier ใน View ของคุณ
extension View {
    func detectRotation() -> some View {
        self.modifier(DeviceRotationAwareModifier())
    }
}
