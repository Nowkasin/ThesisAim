//
//  mainView.swift
//  BeActive
//
//  Created by Kasin Thappawan on 17/10/2567 BE.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            // The first tab: a placeholder or any view you want
            Text("Main Menu")
                .font(.largeTitle)
                .tabItem {
                    Label("Main", systemImage: "house.fill")
                }

            // The second tab: The HomeView
            HomeView()
                .tabItem {
                    Label("Mate", systemImage: "person.circle.fill")
                }
        }
    }
}

#Preview {
    MainView()
}
