//
//  Extentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation

final class PreviewExtentions {
    static let previewTodo = Todo(deadline: .now, text: "Test todo", folderId: UUID().uuidString)
    static let previewFolder = Folder(name: "Test folder", userId: UUID().uuidString)
    static func previewCallback() async throws {}
}
