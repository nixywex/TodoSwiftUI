//
//  NewFolderView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct NewFolderView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    
    @State var text = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Create a new Folder") {
                    TextField("New folder", text: $text)
                }
            }
            .scrollDisabled(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if handleSave() { dismiss() }
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
    }
}

extension NewFolderView {
    private func handleSave() -> Bool {
        let _ = FolderEntity.createNewFolder(context: managedObjectContext, name: text)
        return PersistenceController.saveChanges(context: managedObjectContext)
    }
}

#Preview {
    NewFolderView()
}
