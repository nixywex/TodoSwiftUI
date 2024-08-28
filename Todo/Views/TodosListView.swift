//
//  TodosListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct TodosListView: View {
    private var todos: FetchRequest<TodoEntity>
    let sortType: TodoEntity.SortType
    let searchTerm: String
    var folder: FolderEntity
    
    init(sortType: TodoEntity.SortType, searchTerm: String, folder: FolderEntity) {
        self.sortType = sortType
        self.searchTerm = searchTerm
        self.folder = folder
        self.todos = FetchRequest(fetchRequest: TodoEntity.getFetchRequest(from: folder))
    }
    
    var body: some View {
        if todos.wrappedValue.count == 0 &&
            searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            Text("No todos found 🥺")
        } else if todos.wrappedValue.count == 0 {
            Text("You have no todos. Well done! 😁")
        } else {
            List {
                TodosListSectionView(isDoneSection: false, sortType: self.sortType, searchTerm: self.searchTerm, folder: folder)
                TodosListSectionView(isDoneSection: true, sortType: self.sortType, searchTerm: self.searchTerm, folder: folder)
            }
            .listStyle(.sidebar)
        }
    }
}

#Preview {
    TodosListView(sortType: .deadline, searchTerm: "", folder: FolderEntity.getPreviewFolder(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
