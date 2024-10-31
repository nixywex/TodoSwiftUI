//
//  FoldersListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersListView: View {
    @StateObject var vm = FoldersListViewModel()
    
    var folders: [Folder]
    var foldersCallback: () async throws -> Void
    
    var body: some View {
        List {
            ForEach(folders, id: \.id) { folder in
                NavigationLink(destination: FolderView(vm: FolderViewModel(folder: folder), foldersCallback: foldersCallback)) {
                    FolderListItemView(folder: folder)
                }
                .swipeActions() {
                    Button("Delete") {
                        vm.handleDelete(folderId: folder.id)
                        Task {
                            try await foldersCallback()
                        }
                    }
                    .tint(.red)
                }
            }
        }
    }
}

final class FoldersListViewModel: ObservableObject {
    @Published var folders: [Folder]? = nil
    
    func fetchFolders() async throws {
        let userId = try await UserManager.shared.fetchCurrentUser().userId
        let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
        
        DispatchQueue.main.async { self.folders = folders }
    }
    
    func handleDelete(folderId: String) {
        FolderManager.shared.deleteFolder(withId: folderId)
        TodoManager.shared.deleteAllTodosFromFolder(withId: folderId)
    }
}

#Preview {
    FoldersListView(folders: [PreviewExtentions.previewFolder], foldersCallback: PreviewExtentions.previewCallback)
}
