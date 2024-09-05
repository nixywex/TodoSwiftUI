//
//  FolderDetailsViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import Foundation
import CoreData
import SwiftUI

final class FolderDetailsViewModel: ObservableObject {
    var context: NSManagedObjectContext
    var folder: FolderEntity
    var alertController = AlertController(alertHeader: "", alertText: "", alertType: .error, buttonsActions: [], buttonsText: ["", ""])

    @Published var folderName: String
    @Published var isAlertShowed = false
    
    init(folder: FolderEntity, context: NSManagedObjectContext) {
        self.folder = folder
        self.folderName = folder.name
        self.context = context
    }
    
    func handleSave() -> Bool {
        if !FolderEntity.isDataValid(name: folderName) {
            configErrorAlert()
            return false
        }
        
        self.folder.name_ = self.folderName
        
        return PersistenceController.saveChanges(context: context)
    }
    
    func configDeleteAlert() {
        alertController.alertHeader = "Are you sure you want to delete this folder?"
        alertController.alertText = "The folder cannot be restored"
        alertController.alertType = .question
        alertController.buttonsActions = [cancel, deleteFolder]
        alertController.buttonsText = ["Cancel", "Delete"]
        isAlertShowed = true
    }
    
    func configErrorAlert() {
        alertController.alertHeader = "Data not valid"
        alertController.alertText = "Enter the correct data and try again :)"
        alertController.alertType = .error
        alertController.buttonsActions = [cancel]
        alertController.buttonsText = ["OK"]
        isAlertShowed = true
    }
    
    func deleteFolder() {
        context.delete(self.folder)
        let _ = PersistenceController.saveChanges(context: context)
    }
    
    func cancel() {
        
    }
}
