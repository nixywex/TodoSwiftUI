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
                } else if let folders = vm.folders, let inbox = vm.inbox {
                    FoldersListView(folders: folders, inbox: inbox, foldersCallback: vm.fetchFolders)
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
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
        .task {
            await vm.fetchFolders()
        }
        .sheet(isPresented: $vm.isNewFolderSheetShowed, content: {
            NewFolderView(callback: vm.fetchFolders)
        })
    }
}

final class FoldersViewModel: ObservableObject {
    @Published var isNewFolderSheetShowed = false
    @Published var folders: [Folder]?
    @Published var inbox: Folder?
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    var userId: String?
    
    func fetchFolders() async {
        if userId == nil {
            fetchUserId()
        }
        
        guard let userId else {
            let error = Errors.fetchAuthUser
            alert = TodoAlert(error: error)
            isAlertPresented = true
            return
        }
        
        do {
            let folders = try await FolderManager.shared.getFoldersFromUser(withId: userId)
            
            DispatchQueue.main.async {
                self.inbox = folders.first { $0.name == "Inbox" }
                self.folders = folders.filter { $0.isEditable != false }
            }
        } catch {
            alert = TodoAlert(error: error)
            isAlertPresented = true
        }
    }
    
    func fetchUserId() {
        do { self.userId = try AuthManager.shared.getAuthUser().uid }
        catch {
            alert = TodoAlert(error: error)
            isAlertPresented = true
        }
    }
}

#Preview {
    FoldersView()
}
