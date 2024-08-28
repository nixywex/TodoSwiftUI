//
//  FoldersListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: FolderEntity.getAllFetchRequest()) var folders
    
    var body: some View {
        List {
            ForEach(folders) { folder in
                NavigationLink(destination: {
                    FolderView(folder: folder)
                }, label: {
                    FolderListItemView(folder: folder)
                })
                .swipeActions{
                    Button(action: {
                        handleDelete(folder)
                    }, label: {
                        Text("Delete")
                    })
                    .tint(.red)
                }
            }
        }
    }
}

extension FoldersListView {
    func handleDelete(_ folder: FolderEntity) {
        managedObjectContext.delete(folder)
        let _ = PersistenceController.saveChanges(context: managedObjectContext)
    }
}

#Preview {
    FoldersListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
