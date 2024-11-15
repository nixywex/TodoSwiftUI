//
//  UserManager.swift
//  Todo
//
//  Created by Nikita Sheludko on 26.10.24.
//

import Foundation
import FirebaseFirestore

struct DbUser: Codable, Equatable {
    let userId: String
    let email: String
    let name: String
    let dateCreated: Date?
    var todos: [Todo]
    var folders: [Folder]
    
    static func == (lhs: DbUser, rhs: DbUser) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    init(auth: AuthDataResult, name: String) {
        self.userId = auth.uid
        self.email = auth.email ?? "error"
        self.name = name
        self.dateCreated = Date()
        self.todos = []
        self.folders = []
    }
}

final class UserManager {
    static let shared = UserManager()
    let userCollection = Firestore.firestore().collection("users")
    
    private init() {}
    
    private func getUserReference(withId userId: String) -> DocumentReference  {
        return userCollection.document(userId)
    }
    
    func getUser(userId: String) async throws -> DbUser {
        return try await getUserReference(withId: userId).getDocument(as: DbUser.self, decoder: CodableExtentions.getDecoder())
    }
    
    func createNewUserInDb(user: DbUser) throws {
        try getUserReference(withId: user.userId).setData(from: user, merge: false, encoder: CodableExtentions.getEncoder())
        try FolderManager.shared.createNewFolder(withUserId: user.userId, name: "Inbox", isEditable: false)
    }
    
    func updateUserDate(withUserId userId: String, values: [String: Any]) {
        getUserReference(withId: userId).updateData(values)
    }
    
    func updateUser(withId userId: String, values: [String: Any]) {
        getUserReference(withId: userId).updateData(values)
    }
    
    func deleteUser(withId userId: String) async throws {
        try await userCollection.document(userId).delete()
        try await AuthManager.shared.deleteUser()
    }
}
