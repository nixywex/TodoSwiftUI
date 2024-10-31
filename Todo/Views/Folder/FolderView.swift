//
//  FolderView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct FolderView: View {
    @StateObject var vm: FolderViewModel
    
    var foldersCallback: () async throws -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                if let todosNotDone = vm.todosNotDone, let todosDone = vm.todosDone {
                    if todosNotDone.isEmpty {
                        Text("You have no todos. Well done!")
                    } else {
                        List {
                            TodosListSectionView(vm: TodosListSectionViewModel(isDoneSection: false), todos: todosNotDone, foldersCallback: foldersCallback,
                                                 callback: vm.fetchTodos)
                            TodosListSectionView(vm: TodosListSectionViewModel(isDoneSection: true), todos: todosDone, foldersCallback: foldersCallback,
                                                 callback: vm.fetchTodos)
                        }
                        .listStyle(SidebarListStyle())
                    }
                }
                else {
                    Text("Loading...")
                }
            }
            .navigationTitle(vm.folder.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section {
                            Picker("Sort by", selection: $vm.sortType) {
                                Text("Deadline").tag(Todo.SortType.deadline)
                                Text("Todo text").tag(Todo.SortType.text)
                                Text("Priority").tag(Todo.SortType.priority)
                            }
                            .onChange(of: vm.sortType) {
                                Task { try await vm.fetchTodos() }
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
            
        }
        .task {
            do { try await vm.fetchTodos() }
            catch { print("Error fetching todos: \(error.localizedDescription)") }
        }
        .sheet(isPresented: $vm.isNewTodoSheetPresented) {
            NewTodoView(vm: NewTodoViewModel(folder: vm.folder, callback: vm.fetchTodos, foldersCallback: foldersCallback))
        }
    }
}


#Preview {
    FolderView(vm: FolderViewModel(folder: PreviewExtentions.previewFolder), foldersCallback: PreviewExtentions.previewCallback)
}
