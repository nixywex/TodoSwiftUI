//
//  EntitiesExtentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import Foundation
import CoreData

extension TodoEntity {
    var text: String {
        get { text_ ?? "Error" }
        set { text_ = newValue }
    }
    
    var folderId: String {
        get { folderId_ ?? "Error" }
        set { folderId_ = newValue }
    }
    
    var todoId: String {
        get { id_ ?? "Error" }
        set { id_ = newValue }
    }
    
    var todoDescription: String {
        get { todoDescription_ ?? "Error" }
        set { todoDescription_ = newValue }
    }
    
    var deadline: Date {
        get { deadline_ ?? Date() }
        set { deadline_ = newValue }
    }
    
    var createdAt: Date {
        get { createdAt_ ?? Date() }
        set { createdAt_ = newValue }
    }
}

extension FolderEntity {
    var name: String {
        get { name_ ?? "Error" }
        set { name_ = newValue }
    }
    
    var folderId: String {
        get { id_ ?? "Error" }
        set { id_ = newValue }
    }
    
    var userId: String {
        get { userId_ ?? "Error" }
        set { userId_ = newValue }
    }
}
