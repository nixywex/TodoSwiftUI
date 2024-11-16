//
//  FolderView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct FolderView: View {
    @State var sortType: Todo.SortType = .deadline
    @State var isNewTodoSheetPresented = false
    
    var folder: FolderEntity
    
    var body: some View {
        NavigationStack {
            List {
                TodosListSectionView(sortType: sortType, isDoneSection: false, folder: folder)
                TodosListSectionView(sortType: sortType, isDoneSection: true, folder: folder)
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(folder.name)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Picker("Sort by", selection: $sortType) {
                            Text("Deadline").tag(Todo.SortType.deadline)
                            Text("Todo text").tag(Todo.SortType.text)
                            Text("Priority").tag(Todo.SortType.priority)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("\(Image(systemName: "plus"))") {
                    isNewTodoSheetPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $isNewTodoSheetPresented) {
            NewTodoView(vm: NewTodoViewModel(folder: folder))
        }
    }
}

#Preview {
    FolderView(folder: FolderCoreData.preview)
}
