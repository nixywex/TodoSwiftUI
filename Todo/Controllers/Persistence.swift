//
//  Persistence.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//
//  THIS FUNCTIONALITY IS TEMPORARILY NOT USED
//
//import CoreData
//import SwiftUI
//
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    static var preview: PersistenceController = {
//        let result = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//        for j in 0..<5 {
//            let newFolder = FolderEntity(context: viewContext)
//            newFolder.name_ = "Folder \(j)"
//            newFolder.id = UUID()
//            for i in 0..<5 {
//                let deadline = Calendar.current.date(byAdding: .day, value: Int.random(in: -5...5), to: .now) ?? .now
//                let start = Bool.random() ? Calendar.current.date(byAdding: .day, value: Int.random(in: -5...0) - 1, to: deadline) : nil
//                var priotiry: TodoEntity.Priority
//                switch Int.random(in: -1...1) {
//                case -1: priotiry = .low
//                case 0: priotiry = .middle
//                case 1: priotiry = .high
//                default: priotiry = .middle
//                }
//                let todo = TodoEntity.createNewTodo(context: viewContext, text: "Task #\(i) Folder \(j)", deadline: deadline,
//                                                    startDate: start, description: "Test description", isDone: Bool.random(), priority: priotiry)
//                newFolder.addToTodos(todo)
//            }
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return result
//    }()
//
//    let container: NSPersistentContainer
//
//    var newContext: NSManagedObjectContext {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.persistentStoreCoordinator = container.persistentStoreCoordinator
//        return context
//    }
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "Todo")
//
//        if inMemory { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        createInbox(context: container.viewContext)
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
//
//    private func createInbox(context: NSManagedObjectContext) {
//        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.getAllFetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name_ == %@", "Inbox")
//
//        do {
//            let result = try context.fetch(fetchRequest)
//            if result.isEmpty {
//                _ = FolderEntity.createNewFolder(context: context, name: "Inbox")
//                try context.save()
//            }
//        } catch {
//            print("Error creating inbox: \(error)")
//        }
//    }
//
//    static func exisits(_ todo: TodoEntity, in context: NSManagedObjectContext) -> TodoEntity? {
//        try? context.existingObject(with: todo.objectID) as? TodoEntity
//    }
//
//    static func findFolderByName(_ name: String, in context: NSManagedObjectContext) -> FolderEntity? {
//        try? context.fetch(FolderEntity.getAllFetchRequest()).first {$0.name == name}
//    }
//
//    static func delete(_ todo: TodoEntity, in context: NSManagedObjectContext) throws {
//        if let existingTodo = exisits(todo, in: context) {
//            context.delete(existingTodo)
//            Task(priority: .background) {
//                try await context.perform { try context.save() }
//            }
//        }
//    }
//
//    static func persist(in context: NSManagedObjectContext) throws {
//        if context.hasChanges { try context.save() }
//    }
//
//    static func saveChanges(context: NSManagedObjectContext) -> Bool {
//        do {
//            try PersistenceController.persist(in: context)
//            return true
//        } catch { return false }
//    }
//}

import CoreData
import SwiftUI

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    static var preview: CoreDataManager = {
        let result = CoreDataManager()
        let viewContext = result.persistanceContainer.viewContext
        for j in 0..<5 {
            let newFolder = FolderEntity(context: viewContext)
            newFolder.name_ = "Folder \(j)"
            newFolder.folderId = UUID().uuidString
            for i in 0..<5 {
                let deadline = Calendar.current.date(byAdding: .day, value: Int.random(in: -5...5), to: .now) ?? .now
                let start = Bool.random() ? Calendar.current.date(byAdding: .day, value: Int.random(in: -5...0) - 1, to: deadline) : nil
                var priotiry = Int16(Int.random(in: -1...1))
                let todo = Todo(deadline: deadline, text: "Task #\(i) Folder \(j)", folderId: newFolder.folderId)
                TodoCoreData.add(todo: todo, context: viewContext)
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
    
    lazy var persistanceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private init() { }
}

extension CoreDataManager {
    func save() {
        guard persistanceContainer.viewContext.hasChanges else { return }
        do {
            try persistanceContainer.viewContext.save()
            self.objectWillChange.send()
        }
        catch { print("Error saving context: \(error.localizedDescription)") }
    }
    
    func push() throws {
        guard let userId = AuthManager.shared.user?.userId else { throw Errors.fetchAuthUser }
        
        let todos = try Array(persistanceContainer.viewContext.fetch(TodoCoreData.request)).map { todo in
            return [
                "deadline": todo.deadline,
                "description": todo.todoDescription,
                "id": todo.todoId,
                "is_done": todo.isDone,
                "priority": todo.priority,
                "text": todo.text,
                "start_date": todo.startDate,
                "folder_id": todo.folderId,
                "created_at": todo.createdAt,
            ]
        }
        let folders = try Array(persistanceContainer.viewContext.fetch(FolderCoreData.request)).map { folder in
            return [
                "id": folder.folderId,
                "name": folder.name,
                "number_of_active_todos": folder.numberOfActiveTodos,
                "user_id": folder.userId,
                "is_editable": folder.isEditable
            ]
        }
        
        UserManager.shared.updateUser(withId: userId, values: ["todos": todos])
        UserManager.shared.updateUser(withId: userId, values: ["folders": folders])
        
    }
}

class TodoCoreData {
    static let preview = TodoEntity(context: CoreDataManager.preview.persistanceContainer.viewContext)
    
    static let request: NSFetchRequest = {
        let request = TodoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
        return request
    }()
    
    static let smartPriorityRequest: NSFetchRequest = {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.smartPriority, ascending: true)]
        return request
    }()
    
    static func add(todo: Todo, context: NSManagedObjectContext = CoreDataManager.shared.persistanceContainer.viewContext) {
        let newCDTodo = TodoEntity(context: context)
        newCDTodo.text_ = todo.text
        newCDTodo.createdAt_ = todo.createdAt
        newCDTodo.deadline_ = todo.deadline
        newCDTodo.folderId_ = todo.folderId
        newCDTodo.id_ = todo.id
        newCDTodo.isDone = todo.isDone
        newCDTodo.priority = Int16(todo.priority)
        newCDTodo.startDate = todo.startDate
        newCDTodo.todoDescription_ = todo.description
        newCDTodo.smartPriority = todo.smartPriority
        CoreDataManager.shared.save()
    }
    
    static func delete(todo: TodoEntity) {
        CoreDataManager.shared.persistanceContainer.viewContext.delete(todo)
        CoreDataManager.shared.save()
    }
    
    //TODO: Update this method
    static func getRequest(sortType: Todo.SortType, isDone: Bool) -> NSFetchRequest<TodoEntity> {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.smartPriority, ascending: true)]
        return request
    }
}

extension TodoEntity {
    var text: String {
        get { text_ ?? "Error" }
        set { text_ = newValue }
    }
    
    var folderId: String {
        get { folderId_ ?? "Error" }
        set { folderId_ = newValue }
    }
    
    var todoId: String {
        get { id_ ?? "Error" }
        set { id_ = newValue }
    }
    
    var todoDescription: String {
        get { todoDescription_ ?? "Error" }
        set { todoDescription_ = newValue }
    }
    
    var deadline: Date {
        get { deadline_ ?? Date() }
        set { deadline_ = newValue }
    }
    
    var createdAt: Date {
        get { createdAt_ ?? Date() }
        set { createdAt_ = newValue }
    }
}

class FolderCoreData {
    static let preview = FolderEntity(context: CoreDataManager.preview.persistanceContainer.viewContext)
    
    static let request: NSFetchRequest = {
        let request = FolderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }()
    
    static let inboxRequest: NSFetchRequest = {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isEditable == %@", false)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }()
    
    static func add(folder: Folder) {
        let newCDFolder = FolderEntity(context: CoreDataManager.shared.persistanceContainer.viewContext)
        newCDFolder.name_ = folder.name
        newCDFolder.id_ = folder.id
        newCDFolder.isEditable = folder.isEditable
        newCDFolder.numberOfActiveTodos = Int16(folder.numberOfActiveTodos)
        newCDFolder.userId_ = folder.userId
        CoreDataManager.shared.save()
    }
    
    static func delete(folder: FolderEntity) {
        CoreDataManager.shared.persistanceContainer.viewContext.delete(folder)
        CoreDataManager.shared.save()
    }
}

extension FolderEntity {
    var name: String {
        get { name_ ?? "Error" }
        set { name_ = newValue }
    }
    
    var folderId: String {
        get { id_ ?? "Error" }
        set { id_ = newValue }
    }
    
    var userId: String {
        get { userId_ ?? "Error" }
        set { userId_ = newValue }
    }
}
