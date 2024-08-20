//
//  TodosListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct TodosListView: View {
    @FetchRequest(fetchRequest: TodoEntity.getAllFetchRequest())
    private var todos: FetchedResults<TodoEntity>
    
    let provider: PersistenceController
    
    var body: some View {
        if todos.count == 0 {
            Text("You have no todos. Well done! 😁")
        } else {
            List {
                TodosListSectionView(isDoneSection: false, provider: self.provider)
                TodosListSectionView(isDoneSection: true, provider: self.provider)
            }.listStyle(.sidebar)
        }
    }
}

#Preview {
    TodosListView(provider: .preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
