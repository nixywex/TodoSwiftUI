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
    @Published var todoFolderId: String
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
        self.todoFolderId = todo.folderId
    }
    
    func handleSave() {
        do {
            try TodoManager.validate(text: todoText, deadline: todoDeadline, startDate: todoStartDate, createdAt: todo.createdAt)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
        
        let values: [String: Any] = [
            Todo.Keys.text.rawValue: self.todoText,
            Todo.Keys.deadline.rawValue: self.todoDeadline,
            Todo.Keys.isDone.rawValue: self.isTodoDone,
            Todo.Keys.description.rawValue: self.todoDescription,
            Todo.Keys.priority.rawValue: self.todoPriority.rawValue,
            Todo.Keys.startDate.rawValue: self.todoStartDate,
            Todo.Keys.folderId.rawValue: self.todoFolderId
        ]
        
        TodoManager.shared.updateTodo(withId: todo.id, values: values)
        
        if todo.isDone != self.isTodoDone {
            if todo.isDone {
                FolderManager.shared.numberOfActiveTodosIncrement(withId: todo.folderId)
            } else {
                FolderManager.shared.numberOfActiveTodosDecrement(withId: todo.folderId)

            }
        }
        
        if todo.folderId != self.todoFolderId {
            FolderManager.shared.numberOfActiveTodosDecrement(withId: todo.folderId)
            FolderManager.shared.numberOfActiveTodosIncrement(withId: todoFolderId)
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Do you really want to delete this todo?", type: .delete, message: "You can't undo this action")
        self.isAlertPresented = true
    }
    
    func deleteTodo() {
        TodoManager.shared.deleteTodo(self.todo)
    }
    
    func handleToggle() {
        self.todoStartDate = self.isStartDateOn ? Date() : nil
    }
}

