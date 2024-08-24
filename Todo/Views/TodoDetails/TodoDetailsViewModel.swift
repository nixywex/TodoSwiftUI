//
//  TodoDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData

final class TodoDetailsViewModel: ObservableObject {
    @Published var isAlertShowed: Bool = false
    @Published var isStartDateOn: Bool
    @Published var alertType: TodoDetailsAlertType = .delete
    @Published var alertHeader = "Are you sure you want to delete a todo?"
    @Published var alertText = "The todo cannot be restored"
    
    @Published var todoText: String
    @Published var todoDeadline: Date
    @Published var isTodoDone: Bool
    @Published var todoStartDate: Date?
    @Published var todoDescription: String
    @Published var todoPriority: TodoEntity.Priority
    
    private var todo: TodoEntity
    private let provider: PersistenceController
    
    init(todo: TodoEntity, provider: PersistenceController) {
        self.provider = provider
        self.todo = todo
        self.todoText = todo.text
        self.todoDeadline = todo.deadline
        self.isTodoDone = todo.isDone
        self.todoStartDate = todo.startDate_
        self.todoDescription = todo.todoDescription
        self.isStartDateOn = todo.startDate_ != nil
        self.todoPriority = todo.priority
        print(self.todoPriority)
    }
    
    private func getContext(provider: PersistenceController) -> NSManagedObjectContext {
        return provider.container.viewContext
    }
    
    func handleSave() -> Bool {
        if !TodoEntity.isDataValid(text: self.todoText, deadline: self.todoDeadline, startDate: self.todoStartDate) { return false }
        
        self.todo.text = self.todoText
        self.todo.deadline = self.todoDeadline
        self.todo.isDone = self.isTodoDone
        self.todo.todoDescription = self.todoDescription
        self.todo.startDate_ = self.isStartDateOn ? self.todoStartDate : nil
        self.todo.priority = self.todoPriority
        
        let context = getContext(provider: self.provider)
        
        return PersistenceController.saveChanges(provider: self.provider, context: context)
    }
    
    func handleDelete(todo: TodoEntity) {
        let context = getContext(provider: self.provider)
        do {
            guard let existingTodo = provider.exisits(todo, in: context) else { return }
            try self.provider.delete(existingTodo, in: context)
        } catch { print(error) }
    }
    
    func handleToggle() {
        self.todoStartDate = self.isStartDateOn ? Date() : nil
    }
    
    func configAlert(_ alertType: TodoDetailsAlertType) {
        self.alertType = alertType
        
        switch self.alertType {
        case .delete:
            alertHeader = "Are you sure you want to delete a todo?"
            alertText = "The todo cannot be restored"
        case .invaidData:
            alertHeader = "Data not valid"
            alertText = "Enter the correct data and try again :)"
        }
        
        self.isAlertShowed = true
    }
}

enum TodoDetailsAlertType {
    case delete
    case invaidData
}
