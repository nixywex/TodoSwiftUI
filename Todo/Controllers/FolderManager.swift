//
//  FolderManager.swift
//  Todo
//
//  Created by Nikita Sheludko on 27.10.24.
//

import Foundation
import FirebaseFirestore

struct Folder: Codable {
    let id: String
    var name: String
    let numberOfActiveTodos: Int
    let userId: String
    let isEditable: Bool
    
    init(name: String, userId: String, isEditable: Bool = true) {
        self.id = UUID().uuidString
        self.name = name
        self.numberOfActiveTodos = 0
        self.userId = userId
        self.isEditable = isEditable
    }
    
    enum Keys: String, Codable {
        case userId = "user_id"
        case id = "id"
        case name = "name"
        case numberOfActiveTodos = "number_of_active_todos"
    }
}

final class FolderManager {
    static let shared = FolderManager()
    
    private init() {}
    
    private let foldersCollection = Firestore.firestore().collection("folders")
    
    func createNewFolder(withUserId userId: String, name: String, isEditable: Bool = true) throws {
        let newFolder = Folder(name: name, userId: userId, isEditable: isEditable)
        do {
            try foldersCollection.document(newFolder.id).setData(from: newFolder, merge: false, encoder: CodableExtentions.getEncoder())
        } catch { throw Errors.creatingNewFolder }
    }
    
    private func getFolder(withId folderId: String) -> DocumentReference {
        return foldersCollection.document(folderId)
    }
    
    func getFolder(withId folderId: String) async throws -> Folder {
        try await foldersCollection
            .whereField(Folder.Keys.id.rawValue, isEqualTo: folderId)
            .getDocuments(as: Folder.self)[0]
    }
    
    func getFoldersFromUser(withId userId: String) async throws -> [Folder] {
        try await foldersCollection
            .whereField(Folder.Keys.userId.rawValue, isEqualTo: userId)
            .getDocuments(as: Folder.self)
    }
    
    func updateFolder(withId folderId: String, values: [String: Any]) {
        foldersCollection.document(folderId).updateData(values)
    }
    
    func updateNumberOfActiveTodosInFolder(withId folderId: String, to number: Int) {
        Task {
            let folder = try await FolderManager.shared.getFolder(withId: folderId)
            FolderManager.shared.updateFolder(withId: folder.id, values: [Folder.Keys.numberOfActiveTodos.rawValue: folder.numberOfActiveTodos + number])
        }
    }
    
    func deleteFolder(withId folderId: String) {
        foldersCollection.document(folderId).delete()
    }
    
    func deleteAllTodosAndFoldersFromUser(withId userId: String) {
        Task {
            let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
            folders.forEach { folder in
                TodoManager.shared.deleteAllTodosFromFolder(withId: folder.id)
                FolderManager.shared.deleteFolder(withId: folder.id)
            }
        }
    }
    
    static func validate(name: String) throws {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw Errors.folderName }
        guard name.lowercased() != "inbox" else { throw Errors.folderNameInbox }
    }
}
