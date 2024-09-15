//
//  FolderView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct FolderView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var folder: FolderEntity
    
    @State private var isNewTodoSheetShowed: Bool = false
    @State var sortType: TodoEntity.SortType = .deadline
    @State var searchTerm = ""
    
    init(folder: FolderEntity) {
        self.folder = folder
        _sortType = State(initialValue: getSortType())
    }
    
    var body: some View {
        NavigationStack {
            TodosListView(sortType: self.sortType, searchTerm: self.searchTerm, folder: self.folder)
                .searchable(text: $searchTerm, placement: .navigationBarDrawer, prompt: "Search todos")
                .navigationTitle(folder.name_ ?? "")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Section() {
                                Text("Sort by")
                                Picker("Sort by", selection: $sortType) {
                                    Text("Deadline").tag(TodoEntity.SortType.deadline)
                                    Text("Todo text").tag(TodoEntity.SortType.todoText)
                                    Text("Priority").tag(TodoEntity.SortType.priority)
                                }
                                .onChange(of: sortType) {
                                    self.handleSortTypeChange(sortType: self.sortType)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    ToolbarItem (placement: .topBarTrailing) {
                        Button(action: {
                            isNewTodoSheetShowed.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
        }
        .sheet(isPresented: $isNewTodoSheetShowed) {
            NewTodoView(vm: .init(context: managedObjectContext, folder: folder))
        }
    }
}

private extension FolderView {
    private func handleSortTypeChange(sortType: TodoEntity.SortType) {
        do {
            let value = try JSONEncoder().encode(sortType)
            UserDefaults.standard.setValue(value, forKey: "TODOS_SORT_TYPE_KEY")
        }
        catch { print(error) }
    }
    
    private func getSortType() -> TodoEntity.SortType {
        guard let data = UserDefaults.standard.data(forKey: "TODOS_SORT_TYPE_KEY") else { return .deadline }
        do {
            let sortType = try JSONDecoder().decode(TodoEntity.SortType.self, from: data)
            return sortType
        } catch { return .deadline }
    }
}

#Preview {
    FolderView(folder: FolderEntity.getPreviewFolder(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
