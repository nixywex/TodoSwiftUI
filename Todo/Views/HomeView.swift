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
    
    var body: some View {
        NavigationStack {
            TodosListView(provider: provider)
                .navigationTitle("Your todos")
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
                        Button(action: {
                            isNewTodoSheetShowed.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
        }.sheet(isPresented: $isNewTodoSheetShowed) {
            NewTodoView(vm: .init(provider: provider))
        }
    }
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
