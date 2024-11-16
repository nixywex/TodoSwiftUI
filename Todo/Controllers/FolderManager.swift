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
        case isEditable = "is_editable"
    }
    
    static func validate(name: String) throws {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw Errors.folderName }
        guard name.lowercased() != "inbox" else { throw Errors.folderNameInbox }
    }
}
