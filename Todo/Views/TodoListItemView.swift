//
//  TodoListItemView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI

struct TodoListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var vm = TodoListItemViewModel()
    
    var todo: Todo
    var callback: () async throws -> Void
    var foldersCallback: (() async throws -> Void)? = nil
    var folderName: String?
    
    var body: some View {
        HStack {
            Button(action: {
                Task {
                    await vm.checkAsDone(todo: self.todo)
                    try await callback()
                    try await foldersCallback?()
                }
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
                    .foregroundStyle(todo.isDone ? .gray : colorScheme == .dark ? .white : .black)
                Text((todo.startDate == nil ? todo.deadline.prettyDate() :
                        "\(todo.startDate?.prettyDate() ?? "") - \(todo.deadline.prettyDate())") + "\(folderName == nil ? "" : " • " + (folderName ?? ""))")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.light)
                .foregroundStyle(todo.isDone ? .secondary : vm.getDeadlineColor(deadline: todo.deadline))
            }
            .padding(.horizontal, 0)
            .padding(.top, 5)
            
            Spacer()
            
            Image(systemName: "circle.fill")
                .foregroundStyle(todo.isDone ? Color.secondary.opacity(0.6) : vm.getPriorityColor(priority: todo.priority))
                .font(.system(size: 12))
                .opacity(0.6)
        }
        .swipeActions {
            Button(todo.isDone ? "Not done" : "Done") {
                Task {
                    await vm.checkAsDone(todo: todo)
                    try await callback()
                    try await foldersCallback?()
                }
            }
            .tint(.green)
            
            Button("Delete") {
                vm.handleDelete()
            }
            .tint(.red)
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
            if vm.alert?.type == .delete {
                vm.alert?.getDeleteButton(delete: {
                    Task {
                        vm.deleteTodo(todo: todo)
                        vm.alert = nil
                        try await callback()
                        try await foldersCallback?()
                    }
                })
            }
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

final class TodoListItemViewModel: ObservableObject {
    @Published var isAlertPresented: Bool = false
    @Published var alert: TodoAlert?
    
    func checkAsDone(todo: Todo) async {
        TodoManager.shared.updateTodo(withId: todo.id, values: ["is_done": !todo.isDone])
        
        do {
            let folder = try await FolderManager.shared.getFolder(withId: todo.folderId)
            let result = todo.isDone ? folder.numberOfActiveTodos + 1 : folder.numberOfActiveTodos - 1
            
            FolderManager.shared.updateFolder(withId: folder.id, values: [Folder.Keys.numberOfActiveTodos.rawValue: result])
        } catch {
            DispatchQueue.main.async {
                self.alert = TodoAlert(error: error)
                self.isAlertPresented = true
            }
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Do you really want to delete this todo?", type: .delete, message: "You can't undo this action")
        self.isAlertPresented = true
    }
    
    func deleteTodo(todo: Todo) {
        TodoManager.shared.deleteTodo(withId: todo.id)
        if !todo.isDone {
            FolderManager.shared.updateNumberOfActiveTodosInFolder(withId: todo.folderId, to: -1)
        }
    }
    
    func getPriorityColor(priority: Int) -> Color {
        switch priority {
        case -1 : return .green
        case 0: return .yellow
        case 1: return .red
        default : return .blue
        }
    }
    
    func getDeadlineColor(deadline: Date) -> Color {
        let result = Calendar.current.compare(deadline, to: Date.now, toGranularity: .day)
        
        if result == .orderedAscending { return .red }
        else if result == .orderedSame { return .orange }
        return .secondary
    }
}

#Preview {
    TodoListItemView(todo: PreviewExtentions.previewTodo, callback: PreviewExtentions.previewCallback, foldersCallback: PreviewExtentions.previewCallback)
}
