//
//  Extentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData

extension TodoEntity {
    private static var todosFetchRequest: NSFetchRequest<TodoEntity> {
        NSFetchRequest(entityName: "TodoEntity")
    }
    
    static func getAllFetchRequest() -> NSFetchRequest<TodoEntity> {
        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoEntity.deadline_, ascending: true)
        ]
        return request
    }
    
    var text: String {
        get {
            text_ ?? "Error"
        }
        set {
            text_ = newValue
        }
    }
    
    var deadline: Date {
        get {
            deadline_ ?? Date()
        }
        set {
            deadline_ = newValue
        }
    }
}

//preview
extension TodoEntity {
    @discardableResult
    static func getPreviewTodos(count: Int, in context: NSManagedObjectContext) -> [TodoEntity] {
        var todos = [TodoEntity]()
        for i in 0..<count {
            let todo = TodoEntity(context: context)
            todo.text_ = "Task #\(i)"
            todo.deadline_ = Calendar.current.date(byAdding: .day, value: -i, to: .now) ?? .now
            todo.id = UUID()
            todo.isDone = Bool.random()
            
            todos.append(todo)
        }
        return todos
    }
    
    static func getPreviewTodo(context: NSManagedObjectContext = PersistenceController.preview.container.viewContext) -> TodoEntity {
        return getPreviewTodos(count: 1, in: context)[0]
    }
    
    static func getEmptyTodo(context: NSManagedObjectContext) -> TodoEntity {
        return TodoEntity(context: context)
    }
}
