//
//  FolderDetailsView.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import SwiftUI

struct FolderDetailsView: View {
    @ObservedObject var vm: FolderDetailsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Edit your folder") {
                    TextField("Enter folder name", text: $vm.folderName)
                }
                
                Section("Actions") {
                    Button(action: {
                        vm.configAlert(alertType: .delete)
                    }, label: {
                        Text("\(Image(systemName: "trash")) Delete folder")
                            .foregroundStyle(.red)
                    })
                    Button(action: {
                        if vm.handleSave() {
                            dismiss()
                        }
                    }, label: {
                        Text("\(Image(systemName: "tray.and.arrow.down")) Save")
                            .bold()
                    })
                }
            }
            .navigationTitle(vm.folder.name)
            .navigationBarTitleDisplayMode(.inline)
            .alert(vm.alertTitle, isPresented: $vm.isAlertShowed) {
                Button(vm.alertType == .delete ? "Cancel" : "OK", role: .cancel) {}
                if vm.alertType == .delete {
                    Button("Delete", role: .destructive) {
                        vm.deleteFolder()
                        dismiss()
                    }
                }
            } message: {
                Text(vm.alertText)
            }
        }
    }
}

#Preview {
    FolderDetailsView(vm: FolderDetailsViewModel(folder: FolderEntity.getPreviewFolder(context: PersistenceController.preview.container.viewContext), context: PersistenceController.preview.container.viewContext))
}
