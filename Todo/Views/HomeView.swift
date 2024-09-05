//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct HomeView: View {
    @State var isNewFolderSheetShowed = false
    
    var body: some View {
        NavigationStack {
            FoldersListView()
                .navigationTitle("Your folders")
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            isNewFolderSheetShowed.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
        }
        .sheet(isPresented: $isNewFolderSheetShowed, content: {
            NewFolderView()
        })
    }
}

#Preview {
    FoldersListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
