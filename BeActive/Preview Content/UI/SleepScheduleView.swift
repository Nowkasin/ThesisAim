//
//  SleepScheduleView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 19/3/2568 BE.
//

import SwiftUI

struct SleepScheduleView: View {
    @State private var wakeUpTime = Date()
    @State private var bedTime = Date()
    
    var alertsManager = AlertsManager() // เรียกใช้ AlertsManager
    @Environment(\.presentationMode) var presentationMode // ✅ ใช้ปิดหน้า View
// ให้บันทึกเวลาตื่นนอน และ เวลานอนหลับลง DataBase ด้วย
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ตั้งค่าเวลาตื่น & เวลานอน")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)

                Form {
                    Section(header: Text("⏰ เวลาตื่น").font(.headline)) {
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.orange)
                            DatePicker("เลือกเวลาตื่น", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    
                    Section(header: Text("🌙 เวลานอน").font(.headline)) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                            DatePicker("เลือกเวลานอน", selection: $bedTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()

                // ✅ ปุ่มบันทึกและออกจากหน้านี้
                Button(action: saveSettings) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("บันทึก")
                            .font(.title2)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            
            .navigationBarItems(
                leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            ) // ✅ ปุ่ม X ออกจากหน้า
        }
    }

    // ✅ ฟังก์ชันบันทึกค่าที่เลือก และปิดหน้านี้
    func saveSettings() {
        let calendar = Calendar.current
        let wakeUpComponents = calendar.dateComponents([.hour, .minute], from: wakeUpTime)
        let bedTimeComponents = calendar.dateComponents([.hour, .minute], from: bedTime)
        
        // ✅ ส่งค่าไปที่ AlertsManager และล็อกให้แจ้งเตือนทุก 1 ชั่วโมง
        alertsManager.setWakeUpAndBedTime(wakeUp: wakeUpComponents, bed: bedTimeComponents, interval: 1)
        
        print("✅ ตั้งค่าใหม่: ตื่น \(wakeUpComponents.hour ?? 0):\(wakeUpComponents.minute ?? 0), นอน \(bedTimeComponents.hour ?? 0):\(bedTimeComponents.minute ?? 0), แจ้งเตือนทุก 1 ชม.")
        
        // ✅ ปิดหน้านี้หลังจากบันทึกเสร็จ
        presentationMode.wrappedValue.dismiss()
    }
}

struct SleepScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        SleepScheduleView()
    }
}
