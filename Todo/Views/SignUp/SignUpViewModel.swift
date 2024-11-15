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
            var inbox: [String: Any] {
                let folder = Folder(name: "Inbox", userId: user.userId, isEditable: false)
                return [
                    "id": folder.id,
                    "name": folder.name,
                    "numberOfActiveTodos": folder.numberOfActiveTodos,
                    "userId": folder.userId,
                    "isEditable": folder.isEditable
                ]
            }
            //TODO: Re-write this metod
            let folders = [inbox]
            UserManager.shared.updateUser(withId: authResult.uid, values: ["folders": folders])
            _ = try await AuthManager.shared.fetchAuthUser()
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
