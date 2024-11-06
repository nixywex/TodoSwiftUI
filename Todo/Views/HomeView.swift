//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            GroupBox("Overview") {
                if let todos = vm.todos, let folders = vm.folders {
                    if todos.isEmpty {
                        Text("Add your first todo!")
                            .padding()
                    } else {
                        List {
                            ForEach(todos, id: \.id) { todo in
                                NavigationLink(destination: {
                                    TodoDetailsView(vm: TodoDetailsViewModel(todo: todo), folders: folders, callback: vm.initData)
                                }) {
                                    TodoListItemView(todo: todo, callback: vm.initData,
                                                     folderName: vm.getFolderName(withId: todo.folderId))
                                }
                            }
                        }
                    }
                } else {
                    Text("Loading...")
                }
                Text("\(Image(systemName: "exclamationmark.circle")) Overview shows the top 5 most pressing todos to complete based on priority and deadline.")
                    .font(.system(.caption))
                    .foregroundStyle(.gray)
            }
            .padding()
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("\(Image(systemName: "plus"))") {
                        vm.isNewTodoSheetPresent = true
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            Task { await vm.initData() }
        }
        .sheet(isPresented: $vm.isNewTodoSheetPresent) {
            if let inbox = vm.getInbox() {
                NewTodoView(vm: NewTodoViewModel(folder: inbox), callback: vm.initData, foldersCallback: {})
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresent) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

final class HomeViewModel: ObservableObject {
    @Published var todos: [Todo]?
    @Published var folders: [Folder]?
    @Published var isAlertPresent: Bool = false
    @Published var alert: TodoAlert?
    @Published var isNewTodoSheetPresent: Bool = false
    
    private func fetchTodos(user: DbUser) async throws -> [Todo] {
        return try await TodoManager.shared.getAllTodosFromUser(withId: user.userId)
    }
    
    private func fetchFolders(user: DbUser) async throws -> [Folder] {
        return try await FolderManager.shared.getAllFoldersFromUser(withId: user.userId)
    }
    
    private func sortTodos(_ todos: [Todo]) -> [Todo] {
        let n = todos.count > 5 ? 5 : todos.count
        return Array(todos.sorted { $0.smartPriority < $1.smartPriority}[0..<n])
    }
    
    func initData() async {
        do {
            if AuthManager.shared.user == nil {
                _ = try await AuthManager.shared.fetchAuthUser()
            }
            
            guard let user = AuthManager.shared.user else { throw Errors.fetchAuthUser }
            
            let todos = try await fetchTodos(user: user)
            let folders = try await fetchFolders(user: user)
            
            DispatchQueue.main.async {
                self.todos = self.sortTodos(todos)
                self.folders = folders
            }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert.init(error: error)
                self.isAlertPresent = true
            }
        }
    }
    
    func getFolderName(withId id: String) -> String {
        folders?.first { $0.id == id }?.name ?? ""
    }
    
    func getInbox() -> Folder? {
        folders?.first { $0.isEditable == false } ?? folders?[0]
    }
}

#Preview {
    HomeView()
}
