//
//  NewFodlerViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 27.10.24.
//

import Foundation

final class NewFodlerViewModel: ObservableObject {
    @Published var name = ""
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    func handleSave() async {
        do {
            guard let user = AuthManager.shared.user else { throw Errors.fetchAuthUser }
            try FolderManager.validate(name: name)
            try FolderManager.shared.createNewFolder(withUserId: user.userId, name: self.name)
        }
        catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
