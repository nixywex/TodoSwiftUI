//
//  FolderListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FolderListItemView: View {
    @StateObject var vm = FolderListItemViewModel()
    
    var folder: Folder
    var foldersCallback: (() async throws -> Void)?
    
    var body: some View {
        VStack {
            Text(folder.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(folder.isEditable ? .regular : .bold)
            Text("You have \(folder.numberOfActiveTodos) active todos")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.light)
                .foregroundStyle(.gray)
        }
        .swipeActions() {
            if folder.isEditable {
                Button("Delete") {
                    vm.handleDelete()
                }
                .tint(.red)
                
                NavigationLink(destination: { FolderDetailsView(vm: FolderDetailsViewModel(folder: folder), foldersCallback: foldersCallback ?? {})}) {
                    Button("Edit"){}
                }
                .tint(.blue)
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            let folderIdToDelete = folder.id
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
            if vm.alert?.type == .delete {
                vm.alert?.getDeleteButton(delete: {
                    vm.deleteFolder(folderId: folderIdToDelete)
                    vm.alert = nil
                    Task {
                        try await foldersCallback?()
                    }
                })
            }
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

final class FolderListItemViewModel: ObservableObject {
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
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
    FolderListItemView(folder: PreviewExtentions.previewFolder, foldersCallback: PreviewExtentions.previewCallback)
}
