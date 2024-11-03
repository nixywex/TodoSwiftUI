//
//  TodoManager.swift
//  Todo
//
//  Created by Nikita Sheludko on 27.10.24.
//

import Foundation
import FirebaseFirestore

struct Todo: Codable {
    let deadline: Date
    let description: String
    let id: String
    let isDone: Bool
    let priority: Int
    let text: String
    let startDate: Date?
    let folderId: String
    let createdAt: Date
    
    var smartPriority: Double {
        let difference = self.deadline.timeIntervalSinceNow
        let coefficient = Double(self.priority) + 2
        
        if difference >= 0 { return difference / coefficient }
        else { return difference * coefficient }
    }
    
    init(deadline: Date, text: String, folderId: String, priority: Int = 0, description: String = "", startDate: Date? = nil) {
        self.deadline = deadline
        self.description = description
        self.priority = priority
        self.text = text
        self.startDate = startDate
        self.id = UUID().uuidString
        self.isDone = false
        self.folderId = folderId
        self.createdAt = Date()
    }
    
    enum Priority: Int {
        case low = -1
        case middle = 0
        case high = 1
    }
    
    enum Keys: String, CodingKey {
        case folderId = "folder_id"
        case deadline = "deadline"
        case priority = "priority"
        case text = "text"
        case isDone = "is_done"
        case description = "description"
        case startDate = "start_date"
    }
    
    enum SortType: String, Codable {
        case deadline = "deadline"
        case text = "text"
        case priority = "priority"
    }
}

final class TodoManager {
    static let shared = TodoManager()
    private let todosCollection = Firestore.firestore().collection("todos")
    
    private init() { }
    
    private func getTodo(withId todoId: String) -> DocumentReference {
        return todosCollection.document(todoId)
    }
    
    func createNewTodo(folderId: String, deadline: Date,
                       text: String, priority: Int = 0, description: String = "", startDate: Date? = nil) throws {
        let newTodo = Todo(deadline: deadline, text: text, folderId: folderId, priority: priority, description: description, startDate: startDate)
        try todosCollection.document(newTodo.id).setData(from: newTodo, merge: false, encoder: CodableExtentions.getEncoder())
    }
    
    func updateTodo(withId todoId: String, values: [String: Any]) {
        getTodo(withId: todoId).updateData(values)
    }
    
    func deleteTodo(withId todoId: String) {
        getTodo(withId: todoId).delete()
    }
    
    func getAllTodosInFolder(withId folderId: String) async throws -> [Todo] {
        try await todosCollection.whereField(Todo.Keys.folderId.rawValue, isEqualTo: folderId).getDocuments(as: Todo.self)
    }
    
    func getAllTodosSortedByDate(descending: Bool) async throws -> [Todo] {
        try await todosCollection.order(by: Todo.Keys.deadline.rawValue, descending: descending).getDocuments(as: Todo.self)
    }
    
    func getAllTodosFromUser(withId userId: String) async throws -> [Todo] {
        let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
        var allTodos = [Todo]()
        
        for folder in folders {
            let folderTodos = try await getAllTodosInFolderSorted(by: .priority, descending: true, folderId: folder.id, isDone: false)
            allTodos.append(contentsOf: folderTodos)
        }
        
        return allTodos
    }
    
    func getAllTodosInFolderSorted(by sortType: Todo.SortType, descending: Bool, folderId: String, isDone: Bool) async throws -> [Todo] {
        try await todosCollection
            .whereField(Todo.Keys.folderId.rawValue, isEqualTo: folderId)
            .whereField(Todo.Keys.isDone.rawValue, isEqualTo: isDone)
            .order(by: sortType.rawValue, descending: descending)
            .getDocuments(as: Todo.self)
    }
    
    func getAllTodosInFolderSorted(by sortType: Todo.SortType, descending: Bool, folderId: String) async throws -> [Todo] {
        try await todosCollection
            .whereField(Todo.Keys.folderId.rawValue, isEqualTo: folderId)
            .order(by: sortType.rawValue, descending: descending)
            .getDocuments(as: Todo.self)
    }
    
    func deleteAllTodosFromFolder(withId folderId: String) {
        Task {
            let todos = try await getAllTodosInFolder(withId: folderId)
            todos.forEach { todo in
                deleteTodo(withId: todo.id)
            }
        }
    }
    
    static func validate(text: String, deadline: Date, startDate: Date? = nil, createdAt: Date) throws {
        guard !text.isEmpty else { throw Errors.todoText }
        
        let compareToCreateDate = Calendar.current.compare(deadline, to: createdAt, toGranularity: .day)
        if compareToCreateDate == .orderedAscending { throw Errors.todoDeadline }
        
        if startDate != nil {
            let compareResult = Calendar.current.compare(deadline, to: startDate ?? .now, toGranularity: .day)
            if compareResult != .orderedDescending { throw Errors.todoDeadline }
        }
    }
}
