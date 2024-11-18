//
//  FolderView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct FolderView: View {
    @StateObject var vm = FolderViewModel()
    var folder: FolderEntity
    
    var body: some View {
        NavigationStack {
            List {
                TodosListSectionView(sortType: vm.sortType, isDoneSection: false, folder: folder)
                TodosListSectionView(sortType: vm.sortType, isDoneSection: true, folder: folder)
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(folder.name)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Picker("Sort by", selection: $vm.sortType) {
                            Text("Deadline").tag(Todo.SortType.deadline)
                            Text("Todo text").tag(Todo.SortType.text)
                            Text("Priority").tag(Todo.SortType.priority)
                            Text("Smart priority").tag(Todo.SortType.smart)
                        }
                        .onChange(of: vm.sortType) {
                            vm.handleSortTypeChange()
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("\(Image(systemName: "plus"))") {
                    vm.isNewTodoSheetPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $vm.isNewTodoSheetPresented) {
            NewTodoView(vm: NewTodoViewModel(folder: folder))
        }
    }
}

final class FolderViewModel: ObservableObject {
    @Published var sortType: Todo.SortType = .deadline
    @Published var isNewTodoSheetPresented = false
    
    init() {
        self.sortType = getSortType()
    }
    
    func handleSortTypeChange() {
        let value = try? JSONEncoder().encode(sortType)
        UserDefaults.standard.setValue(value, forKey: "TODOS_SORT_TYPE_KEY")
    }
    
    func getSortType() -> Todo.SortType {
        guard let data = UserDefaults.standard.data(forKey: "TODOS_SORT_TYPE_KEY") else { return .deadline }
        do {
            let sortType = try JSONDecoder().decode(Todo.SortType.self, from: data)
            return sortType
        } catch { return .deadline }
    }
}

#Preview {
    FolderView(folder: FolderCoreData.preview)
}
