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
    @FetchRequest(fetchRequest: FolderCoreData.inboxRequest) private var inbox: FetchedResults<FolderEntity>

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
                                TodoListItemView(todo: todo, folderName: vm.getFolderName(withId: todo.folderId, folders: folders))
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
                    await vm.fetch()
                    vm.isFetchPerformed = true
                }
            }
        }
        .sheet(isPresented: $vm.isNewTodoSheetPresent) {
            if let inbox = inbox.first {
                NewTodoView(vm: NewTodoViewModel(folder: inbox))
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

final class HomeViewModel: ObservableObject {
    @Published var isAlertPresented: Bool = false
    @Published var isNewTodoSheetPresent: Bool = false
    @Published var isFetchPerformed = false
    @Published var alert: TodoAlert?
    
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
    
    func getFolderName(withId id: String, folders: FetchedResults<FolderEntity>) -> String? {
        folders.first { $0.folderId == id }?.name ?? nil
    }
}

#Preview {
    HomeView()
}
