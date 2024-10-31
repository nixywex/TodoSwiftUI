//
//  MainView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct MainView: View {
    @State private var isLoginViewPresented: Bool = false
    
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
            
            ProfileView(isLoginViewPresented: $isLoginViewPresented)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthUser()
            self.isLoginViewPresented = authUser == nil
        }
        .fullScreenCover(isPresented: $isLoginViewPresented) {
            NavigationStack {
                LoginView(isLoginViewPresented: $isLoginViewPresented)
            }
        }
    }
}

#Preview {
    MainView()
}
