//
//  ContentView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: TodoEntity.entity(), sortDescriptors: [])
    
    private var todos: FetchedResults<TodoEntity>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(todos) { todo in
                    Text(todo.text ?? "Error")
                }.onDelete(perform: { indexSet in
                    // delete todo
                })
            }
            .navigationTitle("Your todos")
            .toolbar {
                ToolbarItem (placement: .topBarTrailing) {
                    Button(action: {
                        // create a new todo
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                ToolbarItem (placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }
    
    private func addTodo(text: String, deadline: Date) {
        withAnimation {
            let newTodo = TodoEntity(context: viewContext)
            newTodo.text = text
            newTodo.deadline = deadline
            newTodo.isDone = false
            newTodo.id = UUID()
            
            saveTodos()
        }
    }
    
    private func deleteTodo(offsets: IndexSet) {
        withAnimation {
            guard let index = offsets.first else {return}
            let todo = todos[index]
            viewContext.delete(todo)
            
            saveTodos()
        }
    }
    
    private func saveTodos() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
