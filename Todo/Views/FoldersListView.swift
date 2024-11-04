//
//  FoldersListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersListView: View {    
    var folders: [Folder]
    var inbox: Folder
    var foldersCallback: () async throws -> Void
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: FolderView(vm: FolderViewModel(folder: inbox), folders: folders + [inbox], foldersCallback: foldersCallback)) {
                    FolderListItemView(folder: inbox)
                }
            }
            Section {
                ForEach(folders, id: \.id) { folder in
                    NavigationLink(destination: FolderView(vm: FolderViewModel(folder: folder), folders: folders, foldersCallback: foldersCallback)) {
                        FolderListItemView(folder: folder, foldersCallback: foldersCallback)
                    }
                }
            }
        }
    }
}

#Preview {
    FoldersListView(folders: [PreviewExtentions.previewFolder], inbox: PreviewExtentions.previewFolder, foldersCallback: PreviewExtentions.previewCallback)
}
