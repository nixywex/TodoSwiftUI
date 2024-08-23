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
    
    init(provider: PersistenceController) {
        self.provider = provider
        self.context = provider.newContext
    }
    
    func addTodo() {
        let newTodo = TodoEntity(context: self.context)
        newTodo.text_ = self.text
        newTodo.deadline_ = self.deadline
        newTodo.isDone = false
        newTodo.id = UUID()
        newTodo.todoDescription_ = self.description
        newTodo.startDate_ = self.startDate
        
        saveChanges()
    }
    
    private func saveChanges() {
        do {
            try self.provider.persist(in: self.context)
        } catch {
            print(error)
        }
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
