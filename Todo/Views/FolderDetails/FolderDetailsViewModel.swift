//
//  FolderDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import Foundation
import CoreData

final class FolderDetailsViewModel: ObservableObject {
    var folder: FolderEntity
    var context: NSManagedObjectContext
    
    @Published var folderName: String
    @Published var isAlertShowed = false
    @Published var alertTitle = ""
    @Published var alertText = ""
    @Published var alertType: AlertType = .delete
    
    init(folder: FolderEntity, context: NSManagedObjectContext) {
        self.folder = folder
        self.folderName = folder.name
        self.context = context
    }
    
    func handleSave() -> Bool {
        if !FolderEntity.isDataValid(name: folderName) {
            configAlert(alertType: .invalidData)
            folderName = folder.name
            return false
        }
        
        self.folder.name_ = self.folderName
        
        return PersistenceController.saveChanges(context: context)
    }
    
    func deleteFolder() {
        context.delete(self.folder)
        let _ = PersistenceController.saveChanges(context: context)
    }
    
    func configAlert(alertType: AlertType) {
        self.alertType = alertType
        
        switch alertType {
        case .delete:
            self.alertTitle = "Are you sure you want to delete this folder?"
            self.alertText = "The folder cannot be restored"
        case .invalidData:
            self.alertTitle = "Data not valid"
            self.alertText = "Enter the correct data and try again :)"
        }
        
        self.isAlertShowed.toggle()
    }
}
