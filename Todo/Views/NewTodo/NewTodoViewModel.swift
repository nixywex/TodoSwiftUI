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
    
    let folder: Folder
    var callback: () async throws -> Void
    var foldersCallback: () async throws -> Void
    
    init(folder: Folder, callback: @escaping () async throws -> Void, foldersCallback: @escaping () async throws -> Void) {
        self.folder = folder
        self.callback = callback
        self.foldersCallback = foldersCallback
    }
    
    func handleSaveButton() async -> Bool {
        do {
            try TodoManager.shared.createNewTodo(folderId: folder.id, deadline: deadline, text: text,
                                                 priority: priority.rawValue, description: description, startDate: startDate)
            FolderManager.shared.updateNumberOfActiveTodosInFolder(withId: folder.id, to: 1)
            try await callback()
            try await foldersCallback()
            return true
        } catch {
            print("Error creating new todo: \(error.localizedDescription)")
            return false
        }
    }
    
    func handleToggle() {
        self.startDate = self.isStartDateOn ? Date() : nil
    }
}
