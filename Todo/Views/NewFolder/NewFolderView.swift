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
    var callback: () async throws -> Void
    
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
                        if vm.handleSave() {
                            Task {
                                try await callback()
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
        .task {
            do {
                try await vm.loadCurrentUser()
            } catch {
                print("Error loading a user: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    NewFolderView(callback: PreviewExtentions.previewCallback)
}
