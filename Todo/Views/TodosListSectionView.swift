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
    
    init(sortType: Todo.SortType, isDoneSection: Bool, folder: FolderEntity) {
        let request = TodoCoreData.getRequest(isDone: isDoneSection, sortType: sortType, folder: folder)
        _todos = FetchRequest(fetchRequest: request)
        self.isDoneSection = isDoneSection
        _isSectionExpanded = State(initialValue: !isDoneSection)
    }
    
    var body: some View {
        Section("\(isDoneSection ? "Completed" : "Current") todos", isExpanded: $isSectionExpanded) {
            TodosForEachView(todos: todos)
        }
    }
}

#Preview {
    TodosListSectionView(sortType: Todo.SortType.priority, isDoneSection: true, folder: FolderCoreData.preview)
}
