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
    @Published var name: String
    
    var folder: FolderEntity
    
    init(folder: FolderEntity) {
        self.folder = folder
        self.name = folder.name
    }
    
    func handleSave() {
        do {
            try Folder.validate(name: name)
            folder.name = name
            DispatchQueue.main.async {
                CoreDataManager.shared.save()
            }
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Delete Folder", type: .delete, message: "Are you sure you want to delete this folder?")
        self.isAlertPresented = true
    }
    
    func deleteFolder() {
        FolderCoreData.delete(folder: folder)
    }
}
