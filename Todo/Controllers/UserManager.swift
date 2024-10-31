//
//  UserManager.swift
//  Todo
//
//  Created by Nikita Sheludko on 26.10.24.
//

import Foundation
import FirebaseFirestore

struct DbUser: Codable {
    let userId: String
    let email: String
    let name: String
    let dateCreated: Date?
    
    init(auth: AuthDataResult, name: String) {
        self.userId = auth.uid
        self.email = auth.email ?? "error"
        self.name = name
        self.dateCreated = Date()
    }
}

final class UserManager {
    static let shared = UserManager()
    let userCollection = Firestore.firestore().collection("users")

    private init() {}
        
    private func getUserReference(withId userId: String) -> DocumentReference  {
        return userCollection.document(userId)
    }
    
    private func getUser(userId: String) async throws -> DbUser {
        return try await getUserReference(withId: userId).getDocument(as: DbUser.self, decoder: CodableExtentions.getDecoder())
    }
    
    func createNewUserInDb(user: DbUser) throws {
        try getUserReference(withId: user.userId).setData(from: user, merge: false, encoder: CodableExtentions.getEncoder())
    }
    
    func fetchCurrentUser() async throws -> DbUser {
        let authResult = try AuthManager.shared.getAuthUser()
        return try await UserManager.shared.getUser(userId: authResult.uid)
    }
    
    func updateUserDate(withUserId userId: String, values: [String: Any]) {
        getUserReference(withId: userId).updateData(values)
    }
    
    func deleteUser(withId userId: String) {
        userCollection.document(userId).delete()
    }
}
