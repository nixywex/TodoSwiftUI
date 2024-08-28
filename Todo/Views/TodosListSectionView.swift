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
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var isSectionExpanded = true
    
    init(isDoneSection: Bool, sortType: TodoEntity.SortType, searchTerm: String) {
        self.isDoneSection = isDoneSection
        self.isSectionExpanded = !isDoneSection
        self.todos = FetchRequest(fetchRequest: TodoEntity.getFilteredFetchRequest(isDone: isDoneSection, sortType: sortType, searchTerm: searchTerm))
    }
    
    var body: some View {
        Section("\(isDoneSection ? "Completed" : "Current") todos", isExpanded: $isSectionExpanded) {
            ForEach(todos.wrappedValue) { todo in
                NavigationLink(destination: {
                    TodoDetailsView(todo: todo)
                }, label: {
                    TodoListItemView(todo: todo)
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
        do {
            guard let existingTodo = PersistenceController.exisits(todo, in: self.managedObjectContext) else {fatalError()}
            try PersistenceController.delete(existingTodo, in: self.managedObjectContext)
        } catch {
            print(error)
        }
    }
    
    func handleToggle(todo: TodoEntity) {
        todo.isDone.toggle()
        let _ = PersistenceController.saveChanges(context: self.managedObjectContext)
    }
}

#Preview {
    TodosListSectionView(isDoneSection: Bool.random(), sortType: .deadline, searchTerm: "")
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
