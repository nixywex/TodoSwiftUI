//
//  TodoDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData

final class TodoDetailsViewModel: ObservableObject {
    private var todo: TodoEntity
    private let context: NSManagedObjectContext
    
    @Published var isAlertShowed: Bool = false
    @Published var isStartDateOn: Bool
    @Published var alertType: AlertType = .delete
    @Published var alertHeader = "Are you sure you want to delete a todo?"
    @Published var alertText = "The todo cannot be restored"
    
    @Published var todoText: String
    @Published var todoDeadline: Date
    @Published var isTodoDone: Bool
    @Published var todoStartDate: Date?
    @Published var todoDescription: String
    @Published var todoPriority: TodoEntity.Priority
    @Published var todoFolder: FolderEntity
    
    init(todo: TodoEntity, context: NSManagedObjectContext) {
        self.todo = todo
        self.context = context
        self.todoText = todo.text
        self.todoDeadline = todo.deadline
        self.isTodoDone = todo.isDone
        self.todoStartDate = todo.startDate_
        self.todoDescription = todo.todoDescription
        self.isStartDateOn = todo.startDate_ != nil
        self.todoPriority = todo.priority
        self.todoFolder = todo.folder ?? FolderEntity(context: context)
    }
    
    func handleSave() -> Bool {
        if !TodoEntity.isDataValid(text: self.todoText, deadline: self.todoDeadline, startDate: self.todoStartDate) {
            todoText = todo.text
            return false
        }
        
        self.todo.text = self.todoText
        self.todo.deadline = self.todoDeadline
        self.todo.isDone = self.isTodoDone
        self.todo.todoDescription = self.todoDescription
        self.todo.startDate_ = self.isStartDateOn ? self.todoStartDate : nil
        self.todo.priority = self.todoPriority
        
        let currentFolder = todo.folder!
        currentFolder.handleActiveTodosCounter(todo: self.todo, folder: self.todoFolder)
        
        self.todo.folder = self.todoFolder
                
        return PersistenceController.saveChanges(context: self.context)
    }
    
    func handleDelete(todo: TodoEntity) {
        do {
            guard let existingTodo = PersistenceController.exisits(todo, in: self.context) else { return }
            todo.folder?.subtract()
            try PersistenceController.delete(existingTodo, in: self.context)
        } catch { print(error) }
    }
    
    func handleToggle() {
        self.todoStartDate = self.isStartDateOn ? Date() : nil
    }
    
    func configAlert(_ alertType: AlertType) {
        self.alertType = alertType
        
        switch self.alertType {
        case .delete:
            alertHeader = "Are you sure you want to delete this todo?"
            alertText = "The todo cannot be restored"
        case .invalidData:
            alertHeader = "Data not valid"
            alertText = "Enter the correct data and try again :)"
        }
        
        self.isAlertShowed = true
    }
}
