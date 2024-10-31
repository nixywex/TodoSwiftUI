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
    
    func signUp() {
        guard AuthManager.validate(email: email, password: password, confirmPassword: confirmPassword) else { return }
        
        Task {
            do {
                let authResult = try await AuthManager.shared.createUser(withEmail: email, password: password)
                let user = DbUser(auth: authResult, name: name)
                try UserManager.shared.createNewUserInDb(user: user)
            } catch { print("Error: \(error.localizedDescription)") }
        }
    }
}
