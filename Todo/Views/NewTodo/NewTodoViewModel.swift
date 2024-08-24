//
//  NewTodoViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation
import CoreData

final class NewTodoViewModel: ObservableObject {
    private let provider: PersistenceController
    private let context: NSManagedObjectContext
    
    @Published var isAlertShowed = false
    @Published var alertHeader = "Data not valid"
    @Published var alertText = "Enter the correct data and try again :)"
    
    @Published var isStartDateOn = false
    @Published var text: String = ""
    @Published var deadline: Date = Date()
    @Published var startDate: Date? = nil
    @Published var description: String = ""
    @Published var priority: TodoEntity.Priority = .middle
    
    init(provider: PersistenceController) {
        self.provider = provider
        self.context = provider.newContext
    }
    
    func addTodo() {
        let _ = TodoEntity.createNewTodo(context: self.context, text: self.text, deadline: self.deadline,
                                         startDate: self.startDate, description: self.description, priority: self.priority)
        
        let _ = PersistenceController.saveChanges(provider: self.provider, context: self.context)
        
    }
    
    func hanldeSaveButton() -> Bool {
        if !TodoEntity.isDataValid(text: self.text, deadline: self.deadline, startDate: self.startDate) {
            self.isAlertShowed.toggle()
            return false
        }
        addTodo()
        return true
    }
    
    func handleToggle() {
        self.startDate = self.isStartDateOn ? Date() : nil
    }
}
