//
//  FolderDetailsView.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import SwiftUI

struct FolderDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: FolderDetailsViewModel
    
    var foldersCallback: () async throws -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section("Edit your folder") {
                    TextField("Enter folder name", text: $vm.folder.name)
                }
                
                Section("Actions") {
                    Button("\(Image(systemName: "trash")) Delete folder") {
                        vm.handleDelete()
                    }
                    .tint(.red)
                    Button("\(Image(systemName: "tray.and.arrow.down")) Save") {
                        vm.handleSave()
                        Task {
                            if vm.alert == nil {
                                try await foldersCallback()
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle(vm.folder.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
            if vm.alert?.type == .delete {
                vm.alert?.getDeleteButton(delete: {
                    Task {
                        vm.deleteFolder()
                        try await foldersCallback()
                        vm.alert = nil
                        dismiss()
                    }
                })
            }
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

#Preview {
    FolderDetailsView(vm: FolderDetailsViewModel(folder: PreviewExtentions.previewFolder), foldersCallback: PreviewExtentions.previewCallback)
}