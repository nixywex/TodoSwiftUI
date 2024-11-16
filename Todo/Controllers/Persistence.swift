//
//  Persistence.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import CoreData
import SwiftUI

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistanceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    init() { }
    
    func save() {
        guard persistanceContainer.viewContext.hasChanges else { return }
        do {
            try persistanceContainer.viewContext.save()
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        catch { print("Error saving context: \(error.localizedDescription)") }
    }
    
    func push() throws {
        guard let userId = AuthManager.shared.user?.userId else { throw Errors.fetchAuthUser }
        
        let todos = try getAllTodos().map { todo in
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
        let folders = try getAllFolders().map { folder in
            return [
                "id": folder.folderId,
                "name": folder.name,
                "number_of_active_todos": folder.numberOfActiveTodos,
                "user_id": folder.userId,
                "is_editable": folder.isEditable
            ]
        }
        
        UserManager.shared.updateUserData(withUserId: userId, values: ["todos": todos, "folders": folders])
    }
    
    func clear() throws {
        do {
            let todos = try getAllTodos()
            let folders = try getAllFolders()
            
            todos.forEach { TodoCoreData.delete(todo: $0) }
            folders.forEach { FolderCoreData.delete(folder: $0) }
        } catch {
            throw Errors.clearingCoreData
        }
    }
    
    func getAllTodos() throws -> [TodoEntity] {
        return try Array(persistanceContainer.viewContext.fetch(TodoCoreData.request))
    }
    
    func getAllFolders() throws -> [FolderEntity] {
        return try Array(persistanceContainer.viewContext.fetch(FolderCoreData.request))
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
        DispatchQueue.main.async {
            CoreDataManager.shared.save()
        }
    }
    
    static func delete(todo: TodoEntity) {
        CoreDataManager.shared.persistanceContainer.viewContext.delete(todo)
        DispatchQueue.main.async {
            CoreDataManager.shared.save()
        }
    }
    
    static func getRequest(isDone: Bool, sortType: Todo.SortType = .deadline, folder: FolderEntity) -> NSFetchRequest<TodoEntity> {
        let request = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isDone == %@ AND folderId_ == %@", NSNumber(value: isDone), folder.folderId)
        
        switch sortType {
        case .text: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
        case .deadline: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.deadline_, ascending: true)]
        case .priority: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.priority, ascending: false)]
        }
        
        return request
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
        request.predicate = NSPredicate(format: "name_ == %@", "Inbox")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }()
    
    static let requestWithoutInbox: NSFetchRequest = {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name_ != %@", "Inbox")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }()
    
    static func createInbox(userId: String) {
        var inbox: [String: Any] {
            let folder = Folder(name: "Inbox", userId: userId, isEditable: false)
            return [
                Folder.Keys.id.rawValue: folder.id,
                Folder.Keys.name.rawValue: folder.name,
                Folder.Keys.numberOfActiveTodos.rawValue: folder.numberOfActiveTodos,
                Folder.Keys.userId.rawValue: folder.userId,
                Folder.Keys.isEditable.rawValue: folder.isEditable
            ]
        }
        let folders = [inbox]
        UserManager.shared.updateUserData(withUserId: userId, values: ["folders": folders])
    }
    
    static func add(folder: Folder) {
        let newCDFolder = FolderEntity(context: CoreDataManager.shared.persistanceContainer.viewContext)
        newCDFolder.name_ = folder.name
        newCDFolder.id_ = folder.id
        newCDFolder.isEditable = folder.isEditable
        newCDFolder.numberOfActiveTodos = Int16(folder.numberOfActiveTodos)
        newCDFolder.userId_ = folder.userId
        DispatchQueue.main.async {
            CoreDataManager.shared.save()
        }
    }
    
    private static func getRequest(folderId: String) -> NSFetchRequest<FolderEntity> {
        let request = FolderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id_ == %@", folderId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }
    
    static func delete(folder: FolderEntity) {
        CoreDataManager.shared.persistanceContainer.viewContext.delete(folder)
        DispatchQueue.main.async {
            CoreDataManager.shared.save()
        }
    }
    
    static func getFolderBy(id folderId: String) throws -> FolderEntity? {
        return try CoreDataManager.shared.persistanceContainer.viewContext.fetch(getRequest(folderId: folderId)).first
    }
    
    static func updateNumberOfActiveTodos(inFolderWithId folderId: String, value: Int) throws {
        guard let folder = try? getFolderBy(id: folderId) else { throw Errors.fetchingFolders }
        folder.numberOfActiveTodos += Int16(value)
    }
}
