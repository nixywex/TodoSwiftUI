//
//  FoldersView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FoldersView: View {
    @State var isNewFolderSheetShowed = false
    
    var body: some View {
        NavigationStack {
            VStack {
                FoldersListView()
            }
            .navigationTitle("Your folders")
            .toolbar {
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

#Preview {
    FoldersView()
}
