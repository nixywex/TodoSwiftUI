//
//  ContentView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct HomeView: View {
    let provider = PersistenceController.shared
    
    @State private var isNewTodoSheetShowed: Bool = false
    @State var sortType: TodoEntity.SortType = .deadline
    @State var searchTerm = ""
    
    init() { _sortType = State(initialValue: getSortType()) }
    
    var body: some View {
        NavigationStack {
            TodosListView(sortType: self.sortType, provider: self.provider, searchTerm: self.searchTerm)
                .searchable(text: $searchTerm, placement: .navigationBarDrawer, prompt: "Search todos")
                .navigationTitle("Your todos")
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
                        Button(action: {
                            isNewTodoSheetShowed.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                    ToolbarItem(placement: .topBarLeading) {
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
                }
        }
        .sheet(isPresented: $isNewTodoSheetShowed) {
            NewTodoView(vm: .init(provider: provider))
        }
    }
}

private extension HomeView {
    private func handleSortTypeChange(sortType: TodoEntity.SortType) {
        do {
            let value = try JSONEncoder().encode(sortType)
            UserDefaults.standard.setValue(value, forKey: "SORT_TYPE_KEY")
        }
        catch { print(error) }
    }
    
    private func getSortType() -> TodoEntity.SortType {
        guard let data = UserDefaults.standard.data(forKey: "SORT_TYPE_KEY") else { return .deadline }
        do {
            let sortType = try JSONDecoder().decode(TodoEntity.SortType.self, from: data)
            return sortType
        } catch { return .deadline }
    }
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
