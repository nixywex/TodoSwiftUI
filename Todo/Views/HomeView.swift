//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct HomeView: View {
    private var todos: FetchRequest<TodoEntity>
    @FetchRequest(fetchRequest: FolderCoreData.request) private var folders: FetchedResults<FolderEntity>
    @FetchRequest(fetchRequest: FolderCoreData.inboxRequest) private var inbox: FetchedResults<FolderEntity>
    @State private var isNewTodoSheetPresent: Bool = false
    
    private var isSearching: Bool
    
    init(searchTerm: String) {
        self.isSearching = !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if isSearching {
            self.todos = FetchRequest(fetchRequest: TodoCoreData.getSearchRequest(search: searchTerm))
        } else {
            self.todos = FetchRequest(fetchRequest: TodoCoreData.smartPriorityRequest)
        }
    }
    
    var body: some View {
        NavigationStack {
            if todos.wrappedValue.isEmpty, isSearching {
                Text("No results found")
                    .padding()
            } else if isSearching {
                List {
                    TodosForEachView(todos: todos.wrappedValue, folders: folders)
                }
            } else {
                GroupBox("Overview") {
                    if todos.wrappedValue.isEmpty {
                        Text("Add your first todo!")
                            .padding()
                    } else {
                        List {
                            TodosForEachView(todos: todos.wrappedValue, folders: folders)
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
                            isNewTodoSheetPresent = true
                        }
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: $isNewTodoSheetPresent) {
            if let inbox = inbox.first {
                NewTodoView(vm: NewTodoViewModel(folder: inbox))
            }
        }
    }
}

#Preview {
    HomeView(searchTerm: "")
}
