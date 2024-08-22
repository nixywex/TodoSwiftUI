//
//  ContentView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct HomeView: View {
    let provider = PersistenceController.shared
    
    @State var isNewTodoSheetShowed = false
    @State var sortType: TodoEntity.SortType = .deadline
    
    var body: some View {
        NavigationStack {
            TodosListView(sortType: self.sortType, provider: provider)
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

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
