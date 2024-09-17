//
//  MainView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct MainView: View {
    @State var searchTerm = ""
    
    var body: some View {
        TabView {
            HomeView(searchTerm: searchTerm)
                .searchable(text: $searchTerm, placement: .navigationBarDrawer, prompt: "Search todos")
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
