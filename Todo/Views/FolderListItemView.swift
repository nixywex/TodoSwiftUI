//
//  FolderListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.08.24.
//

import SwiftUI

struct FolderListItemView: View {
    var folder: Folder
    
    var body: some View {
        VStack {
            Text(folder.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("You have \(folder.numberOfActiveTodos) active todos")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.light)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    FolderListItemView(folder: PreviewExtentions.previewFolder)
}
