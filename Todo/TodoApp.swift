//
//  TodoApp.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI
import Firebase

@main
struct TodoApp: App {
    init() { FirebaseApp.configure() }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
