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
    
    var todo: TodoEntity
    
    init(todo: TodoEntity) {
        self.todo = todo
        self.todoText = todo.text
        self.todoDeadline = todo.deadline
        self.isTodoDone = todo.isDone
        self.todoStartDate = todo.startDate
        self.todoDescription = todo.todoDescription
        self.isStartDateOn = todo.startDate != nil
        self.todoPriority = Todo.Priority(rawValue: Int(todo.priority)) ?? .middle
        self.todoFolderId = todo.folderId
    }
    
    func handleSave() {
        do {
            try Todo.validate(text: todoText, deadline: todoDeadline, startDate: todoStartDate, createdAt: todo.createdAt)
            
            if todo.folderId != todoFolderId {
                try FolderCoreData.updateNumberOfActiveTodos(inFolderWithId: todo.folderId, value: -1)
                try FolderCoreData.updateNumberOfActiveTodos(inFolderWithId: todoFolderId, value: 1)
            }
            
            if todo.isDone != isTodoDone {
                try FolderCoreData.updateNumberOfActiveTodos(inFolderWithId: todo.folderId, value: isTodoDone ? -1 : 1)
            }
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
        
        todo.text = todoText
        todo.deadline = todoDeadline
        todo.folderId = todoFolderId
        todo.isDone = isTodoDone
        todo.startDate = todoStartDate
        todo.todoDescription = todoDescription
        todo.priority = Int16(todoPriority.rawValue)
        todo.folderId = todoFolderId
        DispatchQueue.main.async {
            CoreDataManager.shared.save()
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Do you really want to delete this todo?", type: .delete, message: "You can't undo this action")
        self.isAlertPresented = true
    }
    
    func deleteTodo() {
        do {
            try FolderCoreData.updateNumberOfActiveTodos(inFolderWithId: todo.folderId, value: -1)
            TodoCoreData.delete(todo: todo)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
    }
    
    func handleToggle() {
        self.todoStartDate = self.isStartDateOn ? Date() : nil
    }
}

