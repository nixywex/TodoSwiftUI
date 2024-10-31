////
////  TodoEntityExtentions.swift
////  Todo
////
////  Created by Nikita Sheludko on 29.08.24.
////
//
//import Foundation
//import CoreData
//
//  THIS FUNCTIONALITY IS TEMPORARILY NOT USED
//
//extension TodoEntity {
//    private static var todosFetchRequest: NSFetchRequest<TodoEntity> {
//        NSFetchRequest(entityName: "TodoEntity")
//    }
//    
//    enum SortType: Codable {
//        case todoText
//        case deadline
//        case priority
//    }
//    
//    enum Priority: Int {
//        case low = -1
//        case middle = 0
//        case high = 1
//    }
//    
//    static func getFilteredFetchRequest(isDone: Bool, sortType: SortType = .deadline, searchTerm: String, folder: FolderEntity) -> NSFetchRequest<TodoEntity> {
//        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
//        
//        if searchTerm.isEmpty {
//            request.predicate = NSPredicate(format: "isDone == %@ AND folder.name_ == %@", NSNumber(value: isDone), folder.name)
//        } else {
//            request.predicate = NSPredicate(format: "text_ CONTAINS[cd] %@ AND isDone == %@ AND folder.name_ == %@", searchTerm, NSNumber(value: isDone), folder.name)
//        }
//        
//        switch sortType {
//        case .todoText: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
//        case .deadline: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.deadline_, ascending: true)]
//        case .priority: request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.priority_, ascending: false)]
//        }
//        
//        return request
//    }
//    
//    static func getFilteredFetchRequest(searchTerm: String) -> NSFetchRequest<TodoEntity> {
//        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
//        
//        if !searchTerm.isEmpty {
//            request.predicate = NSPredicate(format: "text_ CONTAINS[cd] %@", searchTerm)
//        }
//        
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
//        
//        return request
//    }
//    
//    static func getFetchRequest(from folder: FolderEntity) -> NSFetchRequest<TodoEntity> {
//        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
//        request.predicate = NSPredicate(format: "folder.name_ == %@", folder.name)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
//        return request
//    }
//    
//    static func getAllFetchRequest() -> NSFetchRequest<TodoEntity> {
//        let request: NSFetchRequest<TodoEntity> = todosFetchRequest
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.text_, ascending: true)]
//        return request
//    }
//    
//    var text: String {
//        get { text_ ?? "Error" }
//        set { text_ = newValue }
//    }
//    
//    var deadline: Date {
//        get { deadline_ ?? Date() }
//        set { deadline_ = newValue }
//    }
//    
//    var todoDescription: String {
//        get { todoDescription_ ?? "Error" }
//        set { todoDescription_ = newValue }
//    }
//    
//    var priority: TodoEntity.Priority {
//        get { TodoEntity.getPriority(from: Int(self.priority_)) }
//        set { self.priority_ = Int16(newValue.rawValue) }
//    }
//    
//    var priorityCount: Double {
//        let difference = self.deadline.timeIntervalSinceNow
//        var coefficient = 0.0
//        
//        switch self.priority {
//        case .low:
//            coefficient = 1/2
//        case .middle:
//            coefficient = 1
//        case .high:
//            coefficient = 2
//        }
//        
//        var result = 0.0
//        
//        if difference >= 0 { result = difference / coefficient }
//        else { result = difference * coefficient }
//        
//        return result
//    }
//    
//    var prettyDate: String {
//        guard self.startDate_ != nil else { return self.deadline.formatted(.dateTime.day().month()) }
//        return "\(self.startDate_!.formatted(.dateTime.day().month())) - \(self.deadline.formatted(.dateTime.day().month()))"
//    }
//    
//    static func getPriority(from number: Int) -> TodoEntity.Priority {
//        switch number {
//        case 1: return .high
//        case 0: return .middle
//        case -1: return .low
//        default: return .middle
//        }
//    }
//    
//    static func createNewTodo(context: NSManagedObjectContext, text: String, deadline: Date, startDate: Date?,
//                              description: String, isDone: Bool = false, priority: TodoEntity.Priority) -> TodoEntity {
//        let newTodo = TodoEntity(context: context)
//        
//        newTodo.text_ = text
//        newTodo.deadline_ = deadline
//        newTodo.isDone = isDone
//        newTodo.id = UUID()
//        newTodo.todoDescription_ = description
//        newTodo.startDate_ = startDate
//        newTodo.priority = priority
//        
//        return newTodo
//    }
//    
//    static private func isDateValid(start: Date?, end: Date) -> Bool {
//        guard start != nil else { return true }
//        
//        let compareResult = Calendar.current.compare(end, to: start!, toGranularity: .day)
//        
//        switch compareResult {
//        case .orderedSame: return false
//        case .orderedAscending: return false
//        case .orderedDescending: return true
//        }
//    }
//    
//    static func isDataValid(text: String?, deadline: Date?, startDate: Date?) -> Bool {
//        guard let isTrimmedTextEmpty = text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
//        guard let _ = deadline else { return false }
//        return !isTrimmedTextEmpty && self.isDateValid(start: startDate, end: deadline!)
//    }
//}
