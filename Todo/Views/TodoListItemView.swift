//
//  TodoListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI
import CoreData

struct TodoListItemView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var todo: TodoEntity
    
    var body: some View {
        HStack {
            Button(action: {
                self.handleToggle(todo: self.todo)
            }, label: {
                Image(systemName: self.todo.isDone ? "circle.inset.filled" : "circle")
                    .foregroundStyle(todo.isDone ? .gray : .blue)
                    .font(.system(size: 22))
            })
            .buttonStyle(.plain)
            .padding(.trailing, 10)
            VStack {
                Text(self.todo.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(todo.isDone ? .gray : .black)
                Text(self.todo.prettyDate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.light)
                    .foregroundStyle(todo.isDone ? .gray : getDeadlineColor(deadline: todo.deadline))
            }
            Spacer()
            Image(systemName: "circle.fill")
                .foregroundStyle(todo.isDone ? .gray : getPriorityColor(priority: todo.priority))
                .font(.system(size: 12))
                .opacity(0.6)
            
        }
        .padding(.horizontal, 0)
    }
}

private extension TodoListItemView {
    func handleToggle(todo: TodoEntity) {
        todo.isDone.toggle()
        let _ = PersistenceController.saveChanges(context: self.managedObjectContext)
    }
    
    func getDeadlineColor(deadline: Date) -> Color {
        let result = Calendar.current.compare(deadline, to: Date.now, toGranularity: .day)
        
        if result == .orderedAscending { return .red}
        else if result == .orderedSame { return .orange }
        return .black
    }
    
    func getPriorityColor(priority: TodoEntity.Priority) -> Color {
        switch priority {
        case .low : return .green
        case .middle: return .yellow
        case .high: return .red
        }
    }
}

#Preview {
    TodoListItemView(todo: .getPreviewTodo())
}
