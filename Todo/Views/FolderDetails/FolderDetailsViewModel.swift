//
// FolderDetailsViewModel.swift
// Todo
//
// Created by Nikita Sheludko on 29.08.24.
//

import Foundation

final class FolderDetailsViewModel: ObservableObject {
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    var folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
    
    func handleSave() {
        do {
            try FolderManager.validate(name: folder.name)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
        
        let values: [String: Any] = [
            "name": self.folder.name,
        ]
        
        FolderManager.shared.updateFolder(withId: folder.id, values: values)
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Delete Folder", type: .delete, message: "Are you sure you want to delete this folder?")
        self.isAlertPresented = true
    }
    
    func deleteFolder() async {
        do {
            try await FolderManager.shared.deleteFolder(withFolderId: folder.id)
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
