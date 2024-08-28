//
//  TodosListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct TodosListView: View {
    let sortType: TodoEntity.SortType
    let searchTerm: String
    
    private var todos: FetchRequest<TodoEntity>
    
    init(sortType: TodoEntity.SortType, searchTerm: String) {
        self.todos = FetchRequest(fetchRequest: TodoEntity.getAllFetchRequest(searchTerm: searchTerm))
        self.sortType = sortType
        self.searchTerm = searchTerm
    }
    
    var body: some View {
        if todos.wrappedValue.count == 0 && 
            searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            Text("No todos found 🥺")
        } else if todos.wrappedValue.count == 0 {
            Text("You have no todos. Well done! 😁")
        } else {
            List {
                TodosListSectionView(isDoneSection: false, sortType: self.sortType, searchTerm: self.searchTerm)
                TodosListSectionView(isDoneSection: true, sortType: self.sortType, searchTerm: self.searchTerm)
            }
            .listStyle(.sidebar)
        }
    }
}

#Preview {
    TodosListView(sortType: .deadline, searchTerm: "")
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
