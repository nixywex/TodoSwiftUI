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
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    init(folder: Folder) {
        self.folder = folder
    }
    
    func fetchTodos() async {
        var sortBy: Todo.SortType = .priority
        var descending = false
        
        switch (sortType) {
        case .deadline:
            sortBy = .deadline
        case .priority:
            sortBy = .priority
            descending = true
        case .text:
            sortBy = .text
        }
        
        do {
            let todosNotDone = try await TodoManager.shared.getAllTodosInFolderSorted(by: sortBy, descending: descending, folderId: folder.id, isDone: false)
            let todosDone = try await TodoManager.shared.getAllTodosInFolderSorted(by: sortBy, descending: descending, folderId: folder.id, isDone: true)
            
            DispatchQueue.main.async {
                self.todosNotDone = todosNotDone
                self.todosDone = todosDone
            }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
