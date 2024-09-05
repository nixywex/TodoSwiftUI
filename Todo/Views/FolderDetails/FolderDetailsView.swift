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
    @Environment(\.managedObjectContext) var context

    var body: some View {
        NavigationStack {
            List {
                Section("Edit your folder") {
                    TextField("Enter folder name", text: $vm.folderName)
                }
                
                Section("Actions") {
                    Button(action: {
                        vm.configDeleteAlert()
                    }, label: {
                        Text("\(Image(systemName: "trash")) Delete folder")
                            .foregroundStyle(.red)
                    })
                    Button(action: {
                        //FIXME: View will not updated
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
            .alert(vm.alertController.alertHeader, isPresented: $vm.isAlertShowed) {
                //FIXME: View will not dismissed
                ForEach(vm.alertController.buttons) { button in
                    button
                }
            } message: {
                Text(vm.alertController.alertText)
            }
        }
    }
}

//#Preview {
//    FolderDetailsView(folder: FolderEntity.getPreviewFolder(context: PersistenceController.preview.container.viewContext), deleteAction: () -> Void)
//}
