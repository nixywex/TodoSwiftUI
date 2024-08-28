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
    
    enum SortType: Codable {
        case todoText
        case deadline
        case priority
    }
    
    enum Priority: Int {
        case low = -1
        case middle = 0
        case high = 1
    }
    
    static func getFilteredFetchRequest(isDone: Bool, sortType: SortType = .deadline, searchTerm: String, folder: FolderEntity) -> NSFetchRequest<TodoEntity> {
        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
        
        if searchTerm.isEmpty {
            request.predicate = NSPredicate(format: "isDone == %@ AND folder.name_ == %@", NSNumber(value: isDone), folder.name)
        } else {
            request.predicate = NSPredicate(format: "text_ CONTAINS[cd] %@ AND isDone == %@ AND folder.name_ == %@", searchTerm, NSNumber(value: isDone), folder.name)
        }
        
        switch sortType {
        case .todoText: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
        case .deadline: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.deadline_, ascending: true)]
        case .priority: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.priority_, ascending: false)]
        }
        
        return request
    }
    
    static func getFetchRequest(from folder: FolderEntity) -> NSFetchRequest<TodoEntity> {
        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
        request.predicate = NSPredicate(format: "folder.name_ == %@", folder.name)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
        return request
    }
    
    var text: String {
        get { text_ ?? "Error" }
        set { text_ = newValue }
    }
    
    var deadline: Date {
        get { deadline_ ?? Date() }
        set { deadline_ = newValue }
    }
    
    var todoDescription: String {
        get { todoDescription_ ?? "Error" }
        set { todoDescription_ = newValue }
    }
    
    var priority: TodoEntity.Priority {
        get { TodoEntity.getPriority(from: Int(self.priority_)) }
        set { self.priority_ = Int16(newValue.rawValue) }
    }
    
    var prettyDate: String {
        guard self.startDate_ != nil else { return self.deadline.formatted(.dateTime.day().month()) }
        return "\(self.startDate_!.formatted(.dateTime.day().month())) - \(self.deadline.formatted(.dateTime.day().month()))"
    }
    
    static func getPriority(from number: Int) -> TodoEntity.Priority {
        switch number {
        case 1: return .high
        case 0: return .middle
        case -1: return .low
        default: return .middle
        }
    }
    
    static func createNewTodo(context: NSManagedObjectContext, text: String, deadline: Date, startDate: Date?,
                              description: String, isDone: Bool = false, priority: TodoEntity.Priority) -> TodoEntity {
        let newTodo = TodoEntity(context: context)
        
        newTodo.text_ = text
        newTodo.deadline_ = deadline
        newTodo.isDone = isDone
        newTodo.id = UUID()
        newTodo.todoDescription_ = description
        newTodo.startDate_ = startDate
        newTodo.priority = priority
        
        return newTodo
    }
    
    static private func isDateValid(start: Date?, end: Date) -> Bool {
        guard start != nil else { return true }
        
        let compareResult = Calendar.current.compare(end, to: start!, toGranularity: .day)
        
        switch compareResult {
        case .orderedSame: return false
        case .orderedAscending: return false
        case .orderedDescending: return true
        }
    }
    
    static func isDataValid(text: String?, deadline: Date?, startDate: Date?) -> Bool {
        guard let isTrimmedTextEmpty = text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard let _ = deadline else { return false }
        return !isTrimmedTextEmpty && self.isDateValid(start: startDate, end: deadline!)
    }
}

extension FolderEntity {
    private static var foldersFetchRequest: NSFetchRequest<FolderEntity> {
        NSFetchRequest(entityName: "FolderEntity")
    }
    
    enum SortType: Codable {
        case folderName
        case numberOfTasks
    }
    
    static func getAllFetchRequest() -> NSFetchRequest<FolderEntity> {
        let request: NSFetchRequest<FolderEntity> = foldersFetchRequest
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }
    
    static func getSortedFetchRequest(sortType: FolderEntity.SortType) -> NSFetchRequest<FolderEntity> {
        let request: NSFetchRequest<FolderEntity> = foldersFetchRequest
        
        switch sortType {
        case .folderName: request.sortDescriptors = [ NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        case .numberOfTasks: request.sortDescriptors = [ NSSortDescriptor(keyPath: \FolderEntity.todos?.count, ascending: true)]
        }
        
        return request
    }
    
    var name: String {
        get { name_ ?? "Error" }
        set { name_ = newValue }
    }
    
    func getTodos() -> [TodoEntity] {
        return self.todos?.allObjects as? [TodoEntity] ?? []
    }
    
    static func createNewFolder(context: NSManagedObjectContext, name: String) -> FolderEntity {
        let newFolder = FolderEntity(context: context)
        newFolder.name_ = name
        newFolder.id = UUID()
        newFolder.todos = []
        return newFolder
    }
}

//preview
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
