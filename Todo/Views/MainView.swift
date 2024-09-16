//
//  MainView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            FoldersView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("Folders")
                }
        }
    }
}

#Preview {
    MainView()
}
