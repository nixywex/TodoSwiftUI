//
//  Persistence.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for j in 0..<5 {
            let newFolder = FolderEntity(context: viewContext)
            newFolder.name_ = "Folder \(j)"
            newFolder.id = UUID()
            for i in 0..<5 {
                let deadline = Calendar.current.date(byAdding: .day, value: Int.random(in: -5...5), to: .now) ?? .now
                let start = Bool.random() ? Calendar.current.date(byAdding: .day, value: Int.random(in: -5...0) - 1, to: deadline) : nil
                var priotiry: TodoEntity.Priority
                switch Int.random(in: -1...1) {
                case -1: priotiry = .low
                case 0: priotiry = .middle
                case 1: priotiry = .high
                default: priotiry = .middle
                }
                let todo = TodoEntity.createNewTodo(context: viewContext, text: "Task #\(i) Folder \(j)", deadline: deadline,
                                                    startDate: start, description: "Test description", isDone: Bool.random(), priority: priotiry)
                newFolder.addToTodos(todo)
            }
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    var newContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = container.persistentStoreCoordinator
        return context
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Todo")
        
        if inMemory { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        createInbox(context: container.viewContext)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private func createInbox(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.getAllFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name_ == %@", "Inbox")
        
        do {
            let result = try context.fetch(fetchRequest)
            if result.isEmpty {
                _ = FolderEntity.createNewFolder(context: context, name: "Inbox")
                try context.save()
            }
        } catch {
            print("Error creating inbox: \(error)")
        }
    }
    
    static func exisits(_ todo: TodoEntity, in context: NSManagedObjectContext) -> TodoEntity? {
        try? context.existingObject(with: todo.objectID) as? TodoEntity
    }
    
    static func findFolderByName(_ name: String, in context: NSManagedObjectContext) -> FolderEntity? {
        try? context.fetch(FolderEntity.getAllFetchRequest()).first {$0.name == name}
    }
    
    static func delete(_ todo: TodoEntity, in context: NSManagedObjectContext) throws {
        if let existingTodo = exisits(todo, in: context) {
            context.delete(existingTodo)
            Task(priority: .background) {
                try await context.perform { try context.save() }
            }
        }
    }
    
    static func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges { try context.save() }
    }
    
    static func saveChanges(context: NSManagedObjectContext) -> Bool {
        do {
            try PersistenceController.persist(in: context)
            return true
        } catch { return false }
    }
}
