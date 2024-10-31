//
//  FolderViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 27.10.24.
//

import Foundation

final class FolderViewModel: ObservableObject {
    @Published var isNewTodoSheetPresented = false
    @Published var todosNotDone: [Todo]?
    @Published var todosDone: [Todo]?
    @Published var sortType: Todo.SortType = .deadline
    @Published var folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
    
    func fetchTodos() async throws {
        var sortBy: Todo.SortType = .priority
        
        switch (sortType) {
        case .deadline:
            sortBy = .deadline
        case .priority:
            sortBy = .priority
        case .text:
            sortBy = .text
        }
        
        let todosNotDone = try await TodoManager.shared.getAllTodosInFolderSorted(by: sortBy, descending: true, folderId: folder.id, isDone: false)
        let todosDone = try await TodoManager.shared.getAllTodosInFolderSorted(by: sortBy, descending: true, folderId: folder.id, isDone: true)
        
        DispatchQueue.main.async {
            self.todosNotDone = todosNotDone
            self.todosDone = todosDone
        }
    }
}
