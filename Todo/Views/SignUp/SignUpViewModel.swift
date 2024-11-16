//
//  SignUpViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isAlertPresented = false
    @Published var alert: TodoAlert?
    
    func signUp() async {
        do {
            try AuthManager.validate(email: email, password: password, confirmPassword: confirmPassword, name: name)
            let authResult = try await AuthManager.shared.createUser(withEmail: email, password: password)
            let user = DbUser(auth: authResult, name: name)
            try UserManager.shared.createNewUserInDb(user: user)
            FolderCoreData.createInbox(userId: user.userId)
            _ = try await AuthManager.shared.fetchAuthUser()
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
