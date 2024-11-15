//
//  FolderListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FolderListItemView: View {
    @StateObject var vm = FolderListItemViewModel()
    @ObservedObject var folder: FolderEntity
    
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
                
                NavigationLink(destination: {
                    FolderDetailsView(vm: FolderDetailsViewModel(folder: folder))
                }) {
                    Button("Edit"){}
                }
                .tint(.blue)
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
            if vm.alert?.type == .delete {
                vm.alert?.getDeleteButton(delete: {
                    vm.alert = nil
                    Task {
                        vm.deleteFolder(folder: folder)
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
    
    func deleteFolder(folder: FolderEntity) {
        FolderCoreData.delete(folder: folder)
    }
}

#Preview {
    FolderListItemView(folder: FolderCoreData.preview)
}
