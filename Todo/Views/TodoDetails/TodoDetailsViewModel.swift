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
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    var todo: Todo
    
    init(todo: Todo) {
        self.todo = todo
        self.todoText = todo.text
        self.todoDeadline = todo.deadline
        self.isTodoDone = todo.isDone
        self.todoStartDate = todo.startDate
        self.todoDescription = todo.description
        self.isStartDateOn = todo.startDate != nil
        self.todoPriority = Todo.Priority(rawValue: todo.priority) ?? .middle
    }
    
    func handleSave() {
        do {
            try TodoManager.validate(text: todoText, deadline: todoDeadline, startDate: todoStartDate)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
        
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
        
        if isDone != self.isTodoDone { FolderManager.shared.updateNumberOfActiveTodosInFolder(withId: todo.folderId, to: isDone ? 1 : -1) }
        
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Do you really want to delete this todo?", type: .delete, message: "You can't undo this action")
        self.isAlertPresented = true
    }
    
    func deleteTodo() {
        TodoManager.shared.deleteTodo(withId: self.todo.id)
        FolderManager.shared.updateNumberOfActiveTodosInFolder(withId: todo.folderId, to: -1)
    }
    
    func handleToggle() {
        self.todoStartDate = self.isStartDateOn ? Date() : nil
    }
}

