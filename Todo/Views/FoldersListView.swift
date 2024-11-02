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
                        vm.handleDelete()
                    }
                    .tint(.red)
                    NavigationLink(destination: {
                        FolderDetailsView(vm: FolderDetailsViewModel(folder: folder), foldersCallback: foldersCallback)
                    }) {
                        Button("Edit"){
                            
                        }
                        .tint(.blue)
                    }
                }
                .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
                    vm.alert?.getCancelButton(cancel: { vm.alert = nil })
                    if vm.alert?.type == .delete {
                        vm.alert?.getDeleteButton(delete: {
                            Task {
                                vm.deleteFolder(folderId: folder.id)
                                vm.alert = nil
                                try await foldersCallback()
                            }
                        })
                    }
                } message: {
                    Text(vm.alert?.message ?? "")
                }
            }
        }
        .task {
            await vm.fetchFolders()
        }
    }
}

final class FoldersListViewModel: ObservableObject {
    @Published var folders: [Folder]? = nil
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    func fetchFolders() async {
        do {
            let userId = try await UserManager.shared.fetchCurrentUser().userId
            let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
            
            DispatchQueue.main.async { self.folders = folders }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Delete Folder", type: .delete, message: "Are you sure you want to delete this folder?")
        self.isAlertPresented = true
    }
    
    func deleteFolder(folderId: String) {
        FolderManager.shared.deleteFolder(withId: folderId)
        TodoManager.shared.deleteAllTodosFromFolder(withId: folderId)
    }
}

#Preview {
    FoldersListView(folders: [PreviewExtentions.previewFolder], foldersCallback: PreviewExtentions.previewCallback)
}
