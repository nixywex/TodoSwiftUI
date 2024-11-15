//
//  NewTodoViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation

final class NewTodoViewModel: ObservableObject {
    @Published var isStartDateOn = false
    @Published var text: String = ""
    @Published var deadline: Date = Date()
    @Published var startDate: Date? = nil
    @Published var description: String = ""
    @Published var priority: Todo.Priority = .middle
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    let folder: FolderEntity
    
    init(folder: FolderEntity) {
        self.folder = folder
    }
    
    func handleSaveButton() {
        do {
            try TodoManager.validate(text: text, deadline: deadline, startDate: startDate, createdAt: Date())
            let todo = Todo(deadline: deadline, text: text, folderId: folder.folderId, priority: priority.rawValue, description: description, startDate: startDate)
            TodoCoreData.add(todo: todo)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
    }
    
    func handleToggle() {
        self.startDate = self.isStartDateOn ? Date() : nil
    }
}
