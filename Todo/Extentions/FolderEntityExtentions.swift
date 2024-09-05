//
//  FolderEntityExtentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import Foundation
import CoreData

extension FolderEntity {
    private static var foldersFetchRequest: NSFetchRequest<FolderEntity> {
        NSFetchRequest(entityName: "FolderEntity")
    }
    
    enum SortType: Codable {
        case folderName
        case numberOfTodos
    }
    
    static func getAllFetchRequest() -> NSFetchRequest<FolderEntity> {
        let request: NSFetchRequest<FolderEntity> = foldersFetchRequest
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        return request
    }
    
    var name: String {
        get { name_ ?? "Error" }
        set { name_ = newValue }
    }
    
    var numberOfCurrentTodos: Int {
        return self.getTodos().filter{ !$0.isDone }.count
    }
    
    func getTodos() -> [TodoEntity] {
        return self.todos?.allObjects as? [TodoEntity] ?? []
    }
    
    static func createNewFolder(context: NSManagedObjectContext, name: String) -> FolderEntity {
        let newFolder = FolderEntity(context: context)
        newFolder.name_ = name
        newFolder.id = UUID()
        newFolder.todos = []
        return newFolder
    }
    
    static func isDataValid(name: String) -> Bool {
        return !name.isEmpty
    }
}
