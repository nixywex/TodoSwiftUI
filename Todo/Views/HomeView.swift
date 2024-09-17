//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct HomeView: View {
    var todos: FetchRequest<TodoEntity>
    var searchTerm: String
    
    var sortedTodos: [TodoEntity] {
        Array(todos.wrappedValue.filter { !$0.isDone }.sorted { $0.priorityCount < $1.priorityCount }.prefix(5))
    }
    
    init(searchTerm: String) {
        todos = FetchRequest(fetchRequest: TodoEntity.getFilteredFetchRequest(searchTerm: searchTerm))
        self.searchTerm = searchTerm
    }
    
    var body: some View {
        NavigationStack {
            if !searchTerm.isEmpty && sortedTodos.isEmpty {
                Text("No todos found 🥺")
            } else if !searchTerm.isEmpty {
                HomeViewListView(todos: sortedTodos)
            } else {
                GroupBox("Overview") {
                    if sortedTodos.isEmpty {
                        Text("You have no todos. Well done! 😁")
                            .padding(.vertical, 40)
                    } else {
                        HomeViewListView(todos: sortedTodos)
                            .offset(y: -15)
                            .scrollDisabled(true)
                    }
                    Text("\(Image(systemName: "exclamationmark.circle")) Overview shows the top 5 most pressing todos to complete based on priority and deadline.")
                        .font(.system(.caption))
                        .foregroundStyle(.gray)
                }
                .padding()
                .navigationTitle("Home")

                Spacer()
            }
        }
    }
}

struct HomeViewListView: View {
    var todos: [TodoEntity]
    
    var body: some View {
        List {
            ForEach(todos) { todo in
                NavigationLink(destination: {
                    TodoDetailsView(todo: todo)
                }, label: {
                    TodoListItemView(todo: todo)
                })
            }
        }
    }
}

#Preview {
    HomeView(searchTerm: "")
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
