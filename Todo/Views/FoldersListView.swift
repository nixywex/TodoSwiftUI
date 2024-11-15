//
//  FoldersListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersListView: View {
    @FetchRequest(fetchRequest: FolderCoreData.request) private var folders: FetchedResults<FolderEntity>
    @FetchRequest(fetchRequest: FolderCoreData.inboxRequest) private var inbox: FetchedResults<FolderEntity>
    
    var body: some View {
        List {
            if let inbox = inbox.first {
                Section {
                    NavigationLink(destination: FolderView(folder: inbox)) {
                        FolderListItemView(folder: inbox)
                    }
                }
            }
            
            Section {
                ForEach(folders, id: \.folderId) { folder in
                    NavigationLink(destination: FolderView(folder: folder)) {
                        FolderListItemView(folder: folder)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    FoldersListView()
}
