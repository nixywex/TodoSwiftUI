//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest(fetchRequest: TodoEntity.getAllFetchRequest()) 
    var todos: FetchedResults<TodoEntity>
    
    var sortedTodos: [TodoEntity] {
        Array(todos.filter { !$0.isDone }.sorted { $0.priorityCount < $1.priorityCount }.prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            GroupBox("Overview") {
                if sortedTodos.isEmpty {
                    Text("You have no todos. Well done! 😁")
                        .padding(.vertical, 40)
                } else {
                    List {
                        ForEach(sortedTodos) { todo in
                            NavigationLink(destination: {
                                TodoDetailsView(todo: todo)
                            }, label: {
                                TodoListItemView(todo: todo)
                            })
                        }
                    }
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

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
