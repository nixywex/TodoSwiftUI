//
//  Extentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData
import SwiftUI

extension TodoEntity {
    @discardableResult
    static func getPreviewTodos(count: Int, in context: NSManagedObjectContext) -> [TodoEntity] {
        var todos = [TodoEntity]()
        for i in 0..<count {
            let deadline = Calendar.current.date(byAdding: .day, value: Int.random(in: -5...5), to: .now) ?? .now
            let start = Bool.random() ? Calendar.current.date(byAdding: .day, value: Int.random(in: -5...0) - 1, to: deadline) : nil
            var priotiry: Priority
            
            switch Int.random(in: -1...1) {
            case -1: priotiry = .low
            case 0: priotiry = .middle
            case 1: priotiry = .high
            default: priotiry = .middle
            }
            
            let todo = TodoEntity.createNewTodo(context: context, text: "Task #\(i)", deadline: deadline,
                                                startDate: start, description: "Test description", isDone: Bool.random(), priority: priotiry)
            
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

extension FolderEntity {
    static func getPreviewFolder(context: NSManagedObjectContext) -> FolderEntity {
        let newFolder = FolderEntity(context: context)
        newFolder.name_ = "Test Folder"
        newFolder.id = UUID()
        newFolder.todos = []
        for i in 0..<Int.random(in: 0...0) {
            let deadline = Calendar.current.date(byAdding: .day, value: Int.random(in: -5...5), to: .now) ?? .now
            let start = Bool.random() ? Calendar.current.date(byAdding: .day, value: Int.random(in: -5...0) - 1, to: deadline) : nil
            var priotiry: TodoEntity.Priority
            switch Int.random(in: -1...1) {
            case -1: priotiry = .low
            case 0: priotiry = .middle
            case 1: priotiry = .high
            default: priotiry = .middle
            }
            let todo = TodoEntity.createNewTodo(context: PersistenceController.preview.container.viewContext, text: "Task #\(i)", deadline: deadline,
                                                startDate: start, description: "Test description", isDone: Bool.random(), priority: priotiry)
            newFolder.addToTodos(todo)
        }
        
        return newFolder
    }
}

extension Button: Identifiable {
    public var id: UUID {
        UUID()
    }
}
