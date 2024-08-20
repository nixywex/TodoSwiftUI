//
//  TodoDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData

final class TodoDetailsViewModel: ObservableObject {
    @Published var isAlertShowed: Bool = false
    @Published var todo: TodoEntity
    private let provider: PersistenceController
    
    init(todo: TodoEntity, provider: PersistenceController) {
        self.todo = todo
        self.provider = provider
    }
    
    func getContext(provider: PersistenceController) -> NSManagedObjectContext {
        return provider.container.viewContext
    }
    
    func handleSave() {
        let context = getContext(provider: self.provider)
        do {
            try self.provider.persist(in: context)
        } catch {
            print(error)
        }
    }
    
    func handleDelete(todo: TodoEntity) {
        let context = getContext(provider: self.provider)
        do {
            guard let existingTodo = provider.exisits(todo, in: context) else {fatalError()}
            try self.provider.delete(existingTodo, in: context)
        } catch {
            print(error)
        }
    }
}
