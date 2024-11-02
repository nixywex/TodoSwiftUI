//
//  TodosListSectionView.swift
//  Todo
//
//  Created by Nikita Sheludko on 20.08.24.
//

import SwiftUI

struct TodosListSectionView: View {
    @StateObject var vm: TodosListSectionViewModel
    
    var todos: [Todo]
    var foldersCallback: () async throws -> Void
    var callback: () async throws -> Void
    
    var body: some View {
        Section("\(vm.isDoneSection ? "Completed" : "Current") todos", isExpanded: $vm.isSectionExpanded) {
            ForEach(todos, id: \.id) { todo in
                NavigationLink(destination: {
                    TodoDetailsView(vm: TodoDetailsViewModel(todo: todo), callback: callback, foldersCallback: foldersCallback)
                }) {
                    TodoListItemView(todo: todo, callback: callback, foldersCallback: foldersCallback)
                }
            }
        }
    }
}

final class TodosListSectionViewModel: ObservableObject {
    @Published var isSectionExpanded: Bool
    @Published var isDoneSection: Bool
    
    init(isDoneSection: Bool) {
        self.isSectionExpanded = !isDoneSection
        self.isDoneSection = isDoneSection
    }
}

#Preview {
    TodosListSectionView(vm: TodosListSectionViewModel(isDoneSection: .init(true)), todos: [PreviewExtentions.previewTodo],
                         foldersCallback: PreviewExtentions.previewCallback, callback: PreviewExtentions.previewCallback)
}
