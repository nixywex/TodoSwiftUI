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
    
    private let alertTitle = "Data not valid"
    private let alertText = "Enter the correct data and try again :)"
    
    @State var text = ""
    @State var isAlertPresented = false
    
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
                        else { isAlertPresented.toggle() }
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
        .alert(self.alertTitle, isPresented: $isAlertPresented) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(self.alertText)
        }
    }
}

extension NewFolderView {
    private func handleSave() -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !FolderEntity.isDataValid(name: text) || (PersistenceController.findFolderByName(trimmedText, in: managedObjectContext) != nil) {
            return false
        }
        
        let _ = FolderEntity.createNewFolder(context: managedObjectContext, name: text)
        return PersistenceController.saveChanges(context: managedObjectContext)
    }
}

#Preview {
    NewFolderView()
}
