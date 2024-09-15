//
//  FoldersListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersListView: View {
    var folders: FetchRequest<FolderEntity>

    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var isPresented: Bool

    init(sortType: FolderEntity.SortType) {
        self.folders = FetchRequest(fetchRequest: FolderEntity.getSortedFetchRequest(sortType: sortType))
        self.isPresented = false
    }
    
    var body: some View {
        List {
            Section {
                if let inbox = folders.wrappedValue.first(where: {$0.name_ == "Inbox"}) {
                    NavigationLink(destination: {
                        FolderView(folder: inbox)
                    }, label: {
                        FolderListItemView(folder: inbox)
                            .fontWeight(.semibold)
                    })
                }
            }
            
            ForEach(folders.wrappedValue) { folder in
                if folder.name != "Inbox" {
                    NavigationLink(destination: {
                        FolderView(folder: folder)
                    }, label: {
                        FolderListItemView(folder: folder)
                    })
                    .swipeActions {
                        Button(action: {
                            handleDelete(folder)
                        }, label: {
                            Text("Delete")
                        })
                        .tint(.red)
                        
                        NavigationLink(destination: {
                            FolderDetailsView(vm: FolderDetailsViewModel(folder: folder, context: managedObjectContext))
                        }, label: {
                            Button(action: {}, label: {
                                Text("Edit")
                            })
                        })
                        .tint(.blue)
                    }
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
    FoldersListView(sortType: .folderName)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
