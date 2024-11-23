//
//  TodosForEachView.swift
//  Todo
//
//  Created by Nikita Sheludko on 23.11.24.
//

import SwiftUI

struct TodosForEachView: View {
    var todos: FetchedResults<TodoEntity>
    var folders: FetchedResults<FolderEntity>?
    
    func getFolderName(withId id: String, folders: FetchedResults<FolderEntity>) -> String? {
        folders.first { $0.folderId == id }?.name ?? nil
    }
    
    var body: some View {
        ForEach(todos.prefix(5), id: \.id) { todo in
            NavigationLink(destination: {
                TodoDetailsView(vm: TodoDetailsViewModel(todo: todo))
            }) {
                if let folders {
                    TodoListItemView(todo: todo, folderName: getFolderName(withId: todo.folderId, folders: folders))
                } else {
                    TodoListItemView(todo: todo)
                }
            }
        }
    }
}
