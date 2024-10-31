//
//  TodoDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation

final class TodoDetailsViewModel: ObservableObject {
    @Published var todoText: String
    @Published var todoDeadline: Date
    @Published var isTodoDone: Bool
    @Published var todoStartDate: Date?
    @Published var isStartDateOn: Bool
    @Published var todoDescription: String
    @Published var todoPriority: Todo.Priority
    
    var todo: Todo
    var callback: () async throws -> Void
    var foldersCallback: () async throws -> Void
    
    init(todo: Todo, callback: @escaping () async throws -> Void, foldersCallback: @escaping () async throws -> Void) {
        self.todo = todo
        self.todoText = todo.text
        self.todoDeadline = todo.deadline
        self.isTodoDone = todo.isDone
        self.todoStartDate = todo.startDate
        self.todoDescription = todo.description
        self.isStartDateOn = todo.startDate != nil
        self.todoPriority = Todo.Priority(rawValue: todo.priority) ?? .middle
        self.callback = callback
        self.foldersCallback = foldersCallback
    }
    
    func handleSave() async -> Bool {
        let isDone = todo.isDone
        var values: [String: Any] = [
            "text": self.todoText,
            "deadline": self.todoDeadline,
            "is_done": self.isTodoDone,
            "description": self.todoDescription,
            "priority": self.todoPriority.rawValue
        ]
        
        if let startDate = self.todoStartDate {
            values["start_date"] = startDate
        }
        
        TodoManager.shared.updateTodo(withId: todo.id, values: values)
        
        do {
            if isDone != self.isTodoDone { FolderManager.shared.updateNumberOfActiveTodosInFolder(withId: todo.folderId, to: isDone ? 1 : -1) }
            try await callback()
            try await foldersCallback()
        } catch {
            print("Error saving todo: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func handleDelete() async throws {
        TodoManager.shared.deleteTodo(withId: self.todo.id)
        FolderManager.shared.updateNumberOfActiveTodosInFolder(withId: todo.folderId, to: -1)
        try await callback()
        try await foldersCallback()
    }
    
    func handleToggle() {
        self.todoStartDate = self.isStartDateOn ? Date() : nil
    }
}
