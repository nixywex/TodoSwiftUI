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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    init() { FirebaseApp.configure() }
    
    private func pushDataToFirebase() {
        do {
            try CoreDataManager.shared.push()
        } catch {
            print("Error pushing data to Firebase: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, coreDataManager.persistanceContainer.viewContext)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        pushDataToFirebase()
                    }
                }
        }
    }
}
