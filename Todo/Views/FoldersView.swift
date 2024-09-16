//
//  FoldersView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersView: View {
    @State var isNewFolderSheetShowed = false
    @State var folderSortType: FolderEntity.SortType = .folderName
    
    init() { _folderSortType = State(initialValue: getSortType()) }
    
    var body: some View {
        NavigationStack {
            FoldersListView(sortType: folderSortType)
                .navigationTitle("Your folders")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Section() {
                                Text("Sort by")
                                Picker("Sort by", selection: $folderSortType) {
                                    Text("Name").tag(FolderEntity.SortType.folderName)
                                    Text("Current todos").tag(FolderEntity.SortType.numberOfTodos)
                                }
                                .onChange(of: folderSortType) {
                                    self.handleSortTypeChange(sortType: self.folderSortType)
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing)  {
                        Button(action: {
                            isNewFolderSheetShowed.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
        }
        .sheet(isPresented: $isNewFolderSheetShowed, content: {
            NewFolderView()
        })
    }
}

private extension FoldersView {
    private func handleSortTypeChange(sortType: FolderEntity.SortType) {
        do {
            let value = try JSONEncoder().encode(sortType)
            UserDefaults.standard.setValue(value, forKey: "FOLDER_SORT_TYPE_KEY")
        }
        catch { print(error) }
    }
    
    private func getSortType() -> FolderEntity.SortType {
        guard let data = UserDefaults.standard.data(forKey: "FOLDER_SORT_TYPE_KEY") else { return .folderName }
        do {
            let sortType = try JSONDecoder().decode(FolderEntity.SortType.self, from: data)
            return sortType
        } catch { return .folderName }
    }
}

#Preview {
    FoldersView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
