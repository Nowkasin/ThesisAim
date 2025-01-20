//
//  MatesView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 5/11/2567 BE.
//

import SwiftUI

struct MatesView: View {
    @Environment(\.presentationMode) var presentationMode // ตัวแปรสำหรับควบคุมการนำทาง
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Mate")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

#Preview {
    MatesView()
}
