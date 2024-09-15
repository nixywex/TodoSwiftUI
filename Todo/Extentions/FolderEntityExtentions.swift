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
    
    static func getSortedFetchRequest(sortType: FolderEntity.SortType = .folderName) -> NSFetchRequest<FolderEntity> {
        let request: NSFetchRequest<FolderEntity> = foldersFetchRequest
        
        switch sortType {
        case .folderName:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.name_, ascending: true)]
        case .numberOfTodos:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \FolderEntity.activeTodosCount, ascending: false)]
        }
        
        return request
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
    
    func handleActiveTodosCounter(todo: TodoEntity, folder: FolderEntity) {
        if todo.isDone || todo.folder!.id != folder.id {
            self.subtract()
            folder.add()
        } else {
            self.add()
        }
    }
    
    func handleActiveTodosCounter(todo: TodoEntity) {
        if todo.isDone {
            self.subtract()
        } else {
            self.add()
        }
    }
    
    func add() {
        self.activeTodosCount += 1
    }
    
    func subtract() {
        self.activeTodosCount -= 1
    }
    
    static func createNewFolder(context: NSManagedObjectContext, name: String) -> FolderEntity {
        let newFolder = FolderEntity(context: context)
        newFolder.name_ = name
        newFolder.id = UUID()
        newFolder.todos = []
        newFolder.activeTodosCount = 0
        return newFolder
    }
    
    static func isDataValid(name: String) -> Bool {
        return !name.isEmpty
    }
}
