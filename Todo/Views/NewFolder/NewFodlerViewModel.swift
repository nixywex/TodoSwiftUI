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
    
    func handleSave() -> Bool {
        guard let user else { return false }
        
        do { try FolderManager.shared.createNewFolder(withId: user.userId, name: self.name) }
        catch {
            print("Error creating a new folder: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func loadCurrentUser() async throws {
        let user = try await UserManager.shared.fetchCurrentUser()
        DispatchQueue.main.async { self.user = user }
    }
}
