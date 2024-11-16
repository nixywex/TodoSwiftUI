//
//  PreviewExtentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import Foundation

extension CoreDataManager {
    static var preview: CoreDataManager = {
        let result = CoreDataManager()
        let viewContext = result.persistanceContainer.viewContext
        for j in 0..<5 {
            let newFolder = FolderEntity(context: viewContext)
            newFolder.name_ = "Folder \(j)"
            newFolder.folderId = UUID().uuidString
            for i in 0..<5 {
                let deadline = Calendar.current.date(byAdding: .day, value: Int.random(in: -5...5), to: .now) ?? .now
                let start = Bool.random() ? Calendar.current.date(byAdding: .day, value: Int.random(in: -5...0) - 1, to: deadline) : nil
                var priotiry = Int16(Int.random(in: -1...1))
                let todo = Todo(deadline: deadline, text: "Task #\(i) Folder \(j)", folderId: newFolder.folderId)
                TodoCoreData.add(todo: todo, context: viewContext)
            }
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
