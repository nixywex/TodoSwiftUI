//
//  NewFodlerViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 27.10.24.
//

import Foundation

final class NewFodlerViewModel: ObservableObject {
    @Published var name = ""
    @Published var user: DbUser?
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    func handleSave() async {
        if user == nil {
            Task {
                do {
                    let user = try await UserManager.shared.fetchCurrentUser()
                    DispatchQueue.main.async {
                        self.user = user
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alert = TodoAlert(error: error)
                        self.isAlertPresented = true
                    }
                }
            }
        }
        
        do {
            try FolderManager.validate(name: name)
            try FolderManager.shared.createNewFolder(withId: user!.userId, name: self.name)
        }
        catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
    
    func loadCurrentUser() async {
        do {
            let user = try await UserManager.shared.fetchCurrentUser()
            DispatchQueue.main.async { self.user = user }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
