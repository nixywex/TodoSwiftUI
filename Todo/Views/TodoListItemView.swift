//
//  TodoListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI
import CoreData

struct TodoListItemView: View {    
    @ObservedObject var todo: TodoEntity
    let provider: PersistenceController
    
    var body: some View {
        HStack {
            Button(action: {
                self.handleToggle(todo: self.todo)
            }, label: {
                Image(systemName: self.todo.isDone ? "circle.inset.filled" : "circle")
                    .foregroundStyle(.blue)
                    .font(.system(size: 22))
            })
            .buttonStyle(.plain)
            .padding(.trailing, 10)
            VStack {
                Text(self.todo.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(self.todo.deadline.formatted(.dateTime.day().month()))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.light)
            }
        }
        .padding(.horizontal, 0)
    }
}

private extension TodoListItemView {
    func getContext(provider: PersistenceController) -> NSManagedObjectContext {
        return provider.container.viewContext
    }

    func handleToggle(todo: TodoEntity) {
        let context = getContext(provider: self.provider)
        todo.isDone.toggle()
        do {
            try self.provider.persist(in: context)
        } catch {
            print(error)
        }
    }
}

#Preview {
    TodoListItemView(todo: .getPreviewTodo(), provider: .preview)
}
