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
                                    TodoDetailsView(vm: TodoDetailsViewModel(todo: todo), folders: folders, callback: vm.fetchTodos)
                                }) {
                                    TodoListItemView(todo: todo, callback: vm.fetchTodos,
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
                ToolbarItem {
                    Button("\(Image(systemName: "plus"))") {
                        vm.isNewTodoSheetPresent = true
                    }
                }
            }
            Spacer()
        }
        .task {
            await vm.fetchTodos()
            await vm.fetchFolders()
        }
        .sheet(isPresented: $vm.isNewTodoSheetPresent) {
            if let inbox = vm.getInbox() {
                NewTodoView(vm: NewTodoViewModel(folder: inbox), callback: vm.fetchTodos, foldersCallback: vm.fetchFolders)
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
    
    func fetchTodos() async {
        do {
            let userId = try await UserManager.shared.fetchCurrentUser().userId
            let todos = try await TodoManager.shared.getAllTodosFromUser(withId: userId)
            DispatchQueue.main.async {
                self.todos = self.sortTodos(todos)
            }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert.init(error: error)
                self.isAlertPresent = true
            }
        }
    }
    
    func fetchFolders() async {
        do {
            let userId = try await UserManager.shared.fetchCurrentUser().userId
            let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
            DispatchQueue.main.async {
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
    
    func sortTodos(_ todos: [Todo]) -> [Todo] {
        let n = todos.count > 5 ? 5 : todos.count
        return Array(todos.sorted { $0.smartPriority < $1.smartPriority}[0..<n])
    }
}

#Preview {
    HomeView()
}
