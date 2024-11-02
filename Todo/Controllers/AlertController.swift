//
//  AlertController.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import Foundation
import SwiftUICore
import SwiftUI

enum Errors: Error, LocalizedError {
    case fetchAuthUser
    case signIn
    case deleteUser
    case fetchingTodos
    case creatingNewFolder
    case creatingNewUser
    case login
    case signOut
    case creatingNewTodo
    case updatingTodo
    case fetchingFolders
    case email
    case passwordTooShort
    case passwordsNotMatch
    case name
    case todoText
    case todoDeadline
    case folderName
    
    var errorDescription: String? {
        switch self {
        case .fetchAuthUser:
            return "Unable to fetch user data. Please log out and try again"
        case .signIn:
            return "There was an issue signing in. Please check your credentials and try again"
        case .deleteUser:
            return "Unable to delete your account. Please try again"
        case .fetchingTodos:
            return "Unable to fetch your todos. Please log out and try again"
        case .creatingNewFolder:
            return "Unable to create a new folder. Please try again"
        case .creatingNewUser:
            return "Unable to create a new account. Please try again"
        case .login:
            return "There was an issue logging in. Please try again"
        case .signOut:
            return "Unable to sign out. Please try again"
        case .creatingNewTodo:
            return "Unable to create a new todo item. Please try again"
        case .updatingTodo:
            return "Unable to update this todo. Please try again"
        case .fetchingFolders:
            return "Unable to fetch folders. Please log out and try again"
        case .email:
            return "Please enter a valid email address in the format 'example@domain.com'"
        case .passwordTooShort:
            return "Your password must be at least 8 characters long. Please choose a stronger password"
        case .passwordsNotMatch:
            return "Passwords do not match. Please verify and try again"
        case .name:
            return "Please enter your name to proceed"
        case .todoText:
            return "Please add text for this todo item"
        case .todoDeadline:
            return "The deadline cannot be in the past or earlier than the start date"
        case .folderName:
            return "Please add a name for this folder"
        }
    }
}

struct TodoAlert {
    let title: String
    let type: TodoAlertType
    let message: String?
    
    init(title: String, type: TodoAlertType, message: String? = nil) {
        self.title = title
        self.type = type
        self.message = message
    }
    
    init(error: Error) {
        self.title = "Something went wrong"
        self.type = .error
        self.message = error.localizedDescription
    }
    
    func getCancelButton(cancel: (() -> Void)? = nil) -> Button<Text> {
        var title = ""
        switch type {
        case .delete:
            title = "Cancel"
        case .error:
            title = "OK"
        }
        
        return Button(title, role: .cancel, action: cancel ?? {})
    }
    
    func getDeleteButton(delete: (() -> Void)? = nil) -> Button<Text> {
        return Button("Delete", role: .destructive, action: delete ?? {})
    }
    
    enum TodoAlertType {
        case delete
        case error
    }
}
