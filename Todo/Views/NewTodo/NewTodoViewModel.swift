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
    
    let folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
    
    func handleSaveButton() async {
        do {
            try TodoManager.validate(text: text, deadline: deadline, startDate: startDate, createdAt: Date())
            try TodoManager.shared.createNewTodo(folderId: folder.id, deadline: deadline, text: text,
                                                 priority: priority.rawValue, description: description, startDate: startDate)
            FolderManager.shared.numberOfActiveTodosIncrement(withId: folder.id)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
    }
    
    func handleToggle() {
        self.startDate = self.isStartDateOn ? Date() : nil
    }
}
