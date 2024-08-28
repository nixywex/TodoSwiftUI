//
//  TodosListSectionView.swift
//  Todo
//
//  Created by Nikita Sheludko on 20.08.24.
//

import SwiftUI
import CoreData

struct TodosListSectionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    private var todos: FetchRequest<TodoEntity>
    private let isDoneSection: Bool
    var folder: FolderEntity
    
    @State var isSectionExpanded = true
    
    init(isDoneSection: Bool, sortType: TodoEntity.SortType, searchTerm: String, folder: FolderEntity) {
        self.isDoneSection = isDoneSection
        self.isSectionExpanded = !isDoneSection
        self.todos = FetchRequest(fetchRequest: TodoEntity.getFilteredFetchRequest(isDone: isDoneSection, searchTerm: searchTerm, folder: folder))
        self.folder = folder
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
    TodosListSectionView(isDoneSection: Bool.random(), sortType: .deadline, searchTerm: "", folder: FolderEntity(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
