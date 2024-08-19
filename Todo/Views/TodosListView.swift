//
//  TodosListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI
import CoreData

struct TodosListView: View {
    @FetchRequest(fetchRequest: TodoEntity.getAllFetchRequest())
    private var todos: FetchedResults<TodoEntity>
    
    let provider: PersistenceController
    
    @State var isCurrentTodosSectionExpanded = true
    
    var body: some View {
        if todos.count == 0 {
            Text("You have no todos. Well done! 😁")
        } else {
            List {
                Section("Current todos", isExpanded: $isCurrentTodosSectionExpanded) {
                    ForEach(todos) { todo in
                        NavigationLink(destination: {
                            TodoDetailsView(todo: todo, provider: provider)
                        }, label: {
                            TodoListItemView(todo: todo)
                                .swipeActions {
                                    Button(action: {
                                        do {
                                            try handleDelete(todo: todo)
                                        } catch {
                                            print(error)
                                        }
                                        
                                    }, label: {
                                        Text("Delete")
                                    })
                                    .tint(.red)
                                    
                                    Button(action: {
                                        handleToggle(todo: todo)
                                    }, label: {
                                        Text(todo.isDone ? "Not done" : "Done")
                                    })
                                    .tint(.green)
                                }
                        })
                    }
                }
            }.listStyle(.sidebar)
        }
    }
}

private extension TodosListView {
    func getContext(provider: PersistenceController) -> NSManagedObjectContext {
        let context = provider.container.viewContext
        return context
    }
    
    func handleDelete(todo: TodoEntity) throws {
        let context = self.getContext(provider: self.provider)
        let existingTodo = try context.existingObject(with: todo.objectID)
        
        context.delete(existingTodo)
        Task(priority: .background) {
            try await context.perform {
                try context.save()
            }
        }
    }
    
    func handleToggle(todo: TodoEntity) {
        let context = self.getContext(provider: self.provider)
        
        todo.isDone.toggle()
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}



#Preview {
    TodosListView(provider: .preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
