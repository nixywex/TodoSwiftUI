//
//  TodosListSectionView.swift
//  Todo
//
//  Created by Nikita Sheludko on 20.08.24.
//

import SwiftUI

struct TodosListSectionView: View {
    @FetchRequest private var todos: FetchedResults<TodoEntity>
    @State var isSectionExpanded: Bool
    @State var isDoneSection: Bool
    
    init(sortType: Todo.SortType, isDoneSection: Bool) {
        let request = TodoCoreData.getRequest(sortType: sortType, isDone: isDoneSection)
        _todos = FetchRequest(fetchRequest: request)
        self.isDoneSection = isDoneSection
        _isSectionExpanded = State(initialValue: !isDoneSection)
    }
    
    var body: some View {
        Section("\(isDoneSection ? "Completed" : "Current") todos", isExpanded: $isSectionExpanded) {
            ForEach(todos, id: \.todoId) { todo in
                NavigationLink(destination: {
                    TodoDetailsView(vm: TodoDetailsViewModel(todo: todo))
                }) {
                    TodoListItemView(todo: todo)
                }
            }
        }
    }
}

#Preview {
    TodosListSectionView(sortType: Todo.SortType.priority, isDoneSection: true)
}
