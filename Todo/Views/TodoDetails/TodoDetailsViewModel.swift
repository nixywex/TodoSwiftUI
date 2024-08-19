//
//  TodoDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation

final class TodoDetailsViewModel: ObservableObject {
    @Published var isAlertShowed: Bool = false
    @Published var todo: TodoEntity
    private var provider: PersistenceController
    
    init(todo: TodoEntity, provider: PersistenceController) {
        self.todo = todo
        self.provider = provider
    }
    
    func handleSave() {
        do {
            try self.provider.container.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func handleDelete(todo: TodoEntity) {
        self.provider.container.viewContext.delete(todo)
        self.handleSave()
    }
}
