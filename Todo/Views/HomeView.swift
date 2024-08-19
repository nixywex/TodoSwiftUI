//
//  ContentView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var provider = PersistenceController.shared
    
    @State var isNewTodoSheetShowed = false
    
    var body: some View {
        NavigationStack {
            TodosListView()
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
