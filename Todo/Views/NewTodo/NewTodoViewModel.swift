//
//  NewTodoViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData

final class NewTodoViewModel: ObservableObject {
    private let provider: PersistenceController
    private let context: NSManagedObjectContext
    
    @Published var text: String = ""
    @Published var deadline = Date()
    
    init(provider: PersistenceController) {
        self.provider = provider
        self.context = provider.newContext
    }
    
    func addTodo(text: String, deadline: Date) {
        let newTodo = TodoEntity(context: self.context)
        newTodo.text_ = text
        newTodo.deadline_ = deadline
        newTodo.isDone = false
        newTodo.id = UUID()
        
        saveChanges()
    }
    
    private func saveChanges() {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
