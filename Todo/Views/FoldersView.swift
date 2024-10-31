//
//  FoldersView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersView: View {
    @StateObject var vm = FoldersViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if let folders = vm.folders, folders.isEmpty {
                    Text("You don't have any folders yet. Create one to get started!")
                } else if let folders = vm.folders {
                    FoldersListView(folders: folders, foldersCallback: vm.fetchFolders)
                } else {
                    Text("Loading")
                }
            }
            .navigationTitle("Your folders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing)  {
                    Button(action: {
                        vm.isNewFolderSheetShowed.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
        .task {
            do { try await vm.fetchFolders() }
            catch { print("Error fetching folders: \(error.localizedDescription)") }
        }
        .sheet(isPresented: $vm.isNewFolderSheetShowed, content: {
            NewFolderView(callback: vm.fetchFolders)
        })
    }
}

final class FoldersViewModel: ObservableObject {
    @Published var isNewFolderSheetShowed = false
    @Published var folders: [Folder]?

    var userId: String?
    
    init() {
        do { self.userId = try AuthManager.shared.getAuthUser().uid }
        catch { print("Error fetching user id: \(error.localizedDescription)") }
    }
    
    func fetchFolders() async throws {
        if userId == nil { self.userId = try AuthManager.shared.getAuthUser().uid }
        
        guard let userId else { throw URLError(.badURL) }
        
        let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
        
        DispatchQueue.main.async {
            self.folders = folders
        }
    }
}

#Preview {
    FoldersView()
}
