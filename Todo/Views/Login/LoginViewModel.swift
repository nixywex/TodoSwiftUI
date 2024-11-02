//
//  LoginViewModel.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import Foundation

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSingUpPresented: Bool = false
    @Published var isAlertPresented = false
    @Published var alert: TodoAlert?
    
    func login() async {
        do {
            try AuthManager.validate(email: email, password: password)
            let _ = try await AuthManager.shared.signIn(email: email, password: password)
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
}
