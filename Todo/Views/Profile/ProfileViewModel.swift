//
//  ProfileViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var user: DbUser?
    
    func loadCurrentUser() async throws {
        let user = try await UserManager.shared.fetchCurrentUser()
        
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
    func signOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = self.user else { throw URLError(.badURL) }
        FolderManager.shared.deleteAllTodosAndFoldersFromUser(withId: user.userId)
        try await AuthManager.shared.deleteUser()
        UserManager.shared.deleteUser(withId: user.userId)
    }
}
