//
//  NewFolderView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct NewFolderView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = NewFodlerViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Create a new Folder") {
                    TextField("New folder", text: $vm.name)
                }
            }
            .scrollDisabled(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await vm.handleSave()
                            if vm.alert == nil {
                                dismiss()
                            }
                        }
                    }, label: {
                        Text("Add folder")
                    })
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}


#Preview {
    NewFolderView()
}
