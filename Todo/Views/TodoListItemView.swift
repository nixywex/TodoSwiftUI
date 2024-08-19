//
//  TodoListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI

struct TodoListItemView: View {    
    @ObservedObject var todo: TodoEntity
    @Environment(\.managedObjectContext) private var moc
    
    var body: some View {
        HStack {
            Button(action: {
                handleToggle()
            }, label: {
                Image(systemName: todo.isDone ? "circle.inset.filled" : "circle")
                    .foregroundStyle(.blue)
                    .font(.system(size: 22))
            })
            .buttonStyle(.plain)
            .padding(.trailing, 10)
            VStack {
                Text(todo.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(todo.deadline.formatted(.dateTime.day().month()))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.light)
            }
        }
        .padding(.horizontal, 0)
    }
}

private extension TodoListItemView {
    func handleToggle() {
        todo.isDone.toggle()
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
}

#Preview {
    TodoListItemView(todo: .getPreviewTodo())
}
