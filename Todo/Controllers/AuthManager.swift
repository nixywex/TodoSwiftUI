//
//  AuthManager.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import Foundation
import FirebaseAuth

struct AuthDataResult {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResult(user: authResult.user)
        
        return result
    }
    
    func getAuthUser() throws -> AuthDataResult {
        guard let user = Auth.auth().currentUser
        else { throw URLError(.badServerResponse) }
        
        return AuthDataResult(user: user)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        guard let authResult = try? await Auth.auth().signIn(withEmail: email, password: password)
        else { throw URLError(.badServerResponse) }
        
        return AuthDataResult(user: authResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        try await user.delete()
    }
    
    static func validate(email: String, password: String, confirmPassword: String? = nil) -> Bool {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return false }
        
        if let confirm = confirmPassword {
            if confirm != password { return false }
        }
        
        guard email.contains("@"), email.contains("."), password.count >= 8 else { return false }
        
        return true
    }
}
