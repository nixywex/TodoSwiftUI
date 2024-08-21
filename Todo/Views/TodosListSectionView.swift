//
//  TodosListSectionView.swift
//  Todo
//
//  Created by Nikita Sheludko on 20.08.24.
//

import SwiftUI
import CoreData

struct TodosListSectionView: View {
    @FetchRequest(fetchRequest: TodoEntity.getFilteredFetchRequest(isDone: false))
    private var currentTodos: FetchedResults<TodoEntity>
    
    @FetchRequest(fetchRequest: TodoEntity.getFilteredFetchRequest(isDone: true))
    private var completedTodos: FetchedResults<TodoEntity>
    
    let provider: PersistenceController
    
    let isDoneSection: Bool
    @State var isSectionExpanded = true
    
    init(isDoneSection: Bool, provider: PersistenceController) {
        self.isDoneSection = isDoneSection
        self.isSectionExpanded = !isDoneSection
        self.provider = provider
    }
    
    var body: some View {
        Section("\(isDoneSection ? "Completed" : "Current") todos", isExpanded: $isSectionExpanded) {
            ForEach(isDoneSection ? self.completedTodos : self.currentTodos) { todo in
                NavigationLink(destination: {
                    TodoDetailsView(todo: todo, provider: provider)
                }, label: {
                    TodoListItemView(todo: todo, provider: provider)
                        .swipeActions {
                            Button(action: {
                                self.handleDelete(todo: todo)
                            }, label: {
                                Text("Delete")
                            })
                            .tint(.red)
                            
                            Button(action: {
                                self.handleToggle(todo: todo)
                            }, label: {
                                Text(isDoneSection ? "Not done" : "Done")
                            })
                            .tint(.green)
                        }
                })
            }
        }
    }
}

private extension TodosListSectionView {
    func getContext(provider: PersistenceController) -> NSManagedObjectContext {
        return provider.container.viewContext
    }
    
    func handleDelete(todo: TodoEntity) {
        let context = self.getContext(provider: self.provider)
        do {
            guard let existingTodo = provider.exisits(todo, in: context) else {fatalError()}
            try self.provider.delete(existingTodo, in: context)
        } catch {
            print(error)
        }
    }
    
    func handleToggle(todo: TodoEntity) {
        let context = self.getContext(provider: self.provider)
        todo.isDone.toggle()
        do {
            try self.provider.persist(in: context)
        } catch {
            print(error)
        }
    }
}

#Preview {
    TodosListSectionView(isDoneSection: Bool.random(), provider: .preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
