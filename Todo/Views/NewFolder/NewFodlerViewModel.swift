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
            try FolderManager.validate(name: name)
            guard let userId = AuthManager.shared.user?.userId else { throw Errors.fetchAuthUser }
            let folder = Folder(name: name, userId: userId)
            FolderCoreData.add(folder: folder)
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
