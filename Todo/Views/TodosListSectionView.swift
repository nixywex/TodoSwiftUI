//
//  TodosListSectionView.swift
//  Todo
//
//  Created by Nikita Sheludko on 20.08.24.
//

import SwiftUI
import CoreData

struct TodosListSectionView: View {
    private var todos: FetchRequest<TodoEntity>
    private let isDoneSection: Bool
    let provider: PersistenceController
    
    @State var isSectionExpanded = true
    
    init(isDoneSection: Bool, provider: PersistenceController, sortType: TodoEntity.SortType, searchTerm: String) {
        self.isDoneSection = isDoneSection
        self.isSectionExpanded = !isDoneSection
        self.provider = provider
        self.todos = FetchRequest(fetchRequest: TodoEntity.getFilteredFetchRequest(isDone: isDoneSection, sortType: sortType, searchTerm: searchTerm))
    }
    
    var body: some View {
        Section("\(isDoneSection ? "Completed" : "Current") todos", isExpanded: $isSectionExpanded) {
            ForEach(todos.wrappedValue) { todo in
                NavigationLink(destination: {
                    TodoDetailsView(todo: todo, provider: provider)
                }, label: {
                    TodoListItemView(provider: provider, todo: todo)
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
    func handleDelete(todo: TodoEntity) {
        let context = PersistenceController.getContext(provider: self.provider)
        do {
            guard let existingTodo = provider.exisits(todo, in: context) else {fatalError()}
            try self.provider.delete(existingTodo, in: context)
        } catch {
            print(error)
        }
    }
    
    func handleToggle(todo: TodoEntity) {
        let context = PersistenceController.getContext(provider: self.provider)
        todo.isDone.toggle()
        let _ = PersistenceController.saveChanges(provider: self.provider, context: context)
    }
}

#Preview {
    TodosListSectionView(isDoneSection: Bool.random(), provider: .preview, sortType: .deadline, searchTerm: "")
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
