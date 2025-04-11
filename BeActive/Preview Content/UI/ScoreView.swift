//
//  ScoreView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 24/2/2568 BE.
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject var scoreManager: ScoreManager

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.circle")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.yellow)
            Text("\(scoreManager.totalScore)")
                .font(.headline)
                .padding(8)
                .background(Color.gray) // พื้นหลังสีเทา
                .foregroundColor(.white) // ตัวเลขสีขาว
                .cornerRadius(10) // มุมโค้งมนให้กับพื้นหลัง
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView()
            .environmentObject(ScoreManager.shared)
    }
}


