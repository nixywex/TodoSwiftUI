//
//  MainView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = MainViewModel()
    
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
            
            ProfileView(isLoginViewPresented: $vm.isLoginViewPresented)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .onAppear {
            Task {
                await vm.fetch()
            }
            let user = AuthManager.shared.user
            self.vm.isLoginViewPresented = user != nil
        }
        .fullScreenCover(isPresented: $vm.isLoginViewPresented) {
            NavigationStack {
                LoginView(isLoginViewPresented: $vm.isLoginViewPresented)
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

final class MainViewModel: ObservableObject {
    @Published var alert: TodoAlert?
    @Published var isAlertPresented: Bool = false
    @Published var isLoginViewPresented: Bool = false
    
    func fetch() async {
        do {
            try CoreDataManager.shared.clear()
            _ = try await AuthManager.shared.fetchAuthUser()
            let todosFirebase = AuthManager.shared.user?.todos ?? []
            let foldersFirebase = AuthManager.shared.user?.folders ?? []
            
            todosFirebase.forEach { todo in
                TodoCoreData.add(todo: todo)
            }
            
            foldersFirebase.forEach { folder in
                FolderCoreData.add(folder: folder)
            }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}

#Preview {
    MainView()
}
