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
        guard let authResult = try? await Auth.auth().createUser(withEmail: email, password: password)
        else { throw Errors.creatingNewUser }
        
        let result = AuthDataResult(user: authResult.user)
        
        return result
    }
    
    func getAuthUser() throws -> AuthDataResult {
        guard let user = Auth.auth().currentUser
        else { throw Errors.fetchAuthUser }
        
        return AuthDataResult(user: user)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        guard let authResult = try? await Auth.auth().signIn(withEmail: email, password: password)
        else { throw Errors.signIn }
        
        return AuthDataResult(user: authResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else { throw Errors.deleteUser }
        try await user.delete()
    }
    
    static func validate(email: String, password: String, confirmPassword: String? = nil, name: String? = nil) throws {
        if name != nil { guard let name = name, !name.isEmpty else { throw Errors.name } }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, email.contains("@"), email.contains(".") else { throw Errors.email }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, password.count >= 8  else { throw Errors.passwordTooShort }
        if confirmPassword != nil { guard password == confirmPassword else { throw Errors.passwordsNotMatch } }
    }
}
