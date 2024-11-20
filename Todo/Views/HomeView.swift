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
        .sheet(isPresented: $vm.isNewTodoSheetPresent) {
            if let inbox = inbox.first {
                NewTodoView(vm: NewTodoViewModel(folder: inbox))
            }
        }
    }
}

final class HomeViewModel: ObservableObject {
    @Published var isNewTodoSheetPresent: Bool = false
    
    func getFolderName(withId id: String, folders: FetchedResults<FolderEntity>) -> String? {
        folders.first { $0.folderId == id }?.name ?? nil
    }
}

#Preview {
    HomeView()
}
