//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest(fetchRequest: TodoCoreData.smartPriorityRequest) private var todos: FetchedResults<TodoEntity>
    @FetchRequest(fetchRequest: FolderCoreData.request) private var folders: FetchedResults<FolderEntity>
    
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            GroupBox("Overview") {
                if todos.isEmpty {
                    Text("Add your first todo!")
                        .padding()
                } else {
                    List {
                        ForEach(todos.prefix(5), id: \.id) { todo in
                            NavigationLink(destination: {
                                TodoDetailsView(vm: TodoDetailsViewModel(todo: todo))
                            }) {
                                TodoListItemView(todo: todo, folderName: getFolderName(withId: todo.folderId))
                            }
                        }
                    }
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
            if !vm.isFetchPerformed {
                Task {
                    await fetch()
                    vm.isFetchPerformed = true
                }
            }
        }
        .sheet(isPresented: $vm.isNewTodoSheetPresent) {
            if let inbox = getInbox() {
                NewTodoView(vm: NewTodoViewModel(folder: inbox))
            } else {
                //TODO: Create new inbox
                Text("Something went wrong, we can't find your inbox.")
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

extension HomeView {
    //TODO: move all methods to vm
    private func fetch() async {
        //TODO: Re-write this method
        todos.forEach { TodoCoreData.delete(todo: $0) }
        folders.forEach { FolderCoreData.delete(folder: $0) }
        
        do {
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
                vm.alert = TodoAlert(error: error)
                vm.isAlertPresented = true
            }
        }
    }
    
    private func getFolderName(withId id: String) -> String? {
        folders.first { $0.folderId == id }?.name ?? nil
    }
    
    private func getInbox() -> FolderEntity? {
        folders.first { $0.name == "Inbox" && $0.isEditable == false }
    }
}

final class HomeViewModel: ObservableObject {
    @Published var isAlertPresented: Bool = false
    @Published var isNewTodoSheetPresent: Bool = false
    @Published var isFetchPerformed = false
    @Published var alert: TodoAlert?
}

#Preview {
    HomeView()
}
