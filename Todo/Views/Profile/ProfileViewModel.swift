//
//  ProfileViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var user: DbUser?
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    func loadCurrentUser() async {
        do {
            let user = try await UserManager.shared.fetchCurrentUser()
            
            DispatchQueue.main.async {
                self.user = user
            }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented.toggle()
            }
        }
    }
    
    func signOut() {
        do {
            try AuthManager.shared.signOut()
            self.user = nil
        }
        catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented.toggle()
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Do you really want to delete your account?", type: .delete, message: "You can't undo this action")
        self.isAlertPresented.toggle()
    }
    
    func deleteAccount() async {
        do {
            if user == nil { await loadCurrentUser() }
            guard let user = self.user else { throw Errors.fetchAuthUser }
            FolderManager.shared.deleteAllTodosAndFoldersFromUser(withId: user.userId)
            try await AuthManager.shared.deleteUser()
            UserManager.shared.deleteUser(withId: user.userId)
            DispatchQueue.main.async {
                self.user = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented.toggle()
            }
        }
    }
}
