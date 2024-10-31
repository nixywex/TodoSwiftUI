//
//  LoginViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import Foundation
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPresented: Bool = false
    
    func login() async throws {
        guard AuthManager.validate(email: email, password: password) else { return }
        
        let _ = try await AuthManager.shared.signIn(email: email, password: password)
    }
}
