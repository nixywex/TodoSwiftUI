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
    
    @ObservedObject var todo: TodoEntity
    var folderName: String?
    
    var body: some View {
        HStack {
            Button(action: {
                vm.checkAsDone(todo: todo)
                
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
                Text(vm.getSubtitle(deadline: todo.deadline, startDate: todo.startDate, folderName: folderName))
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
                    vm.checkAsDone(todo: todo)
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
    
    func checkAsDone(todo: TodoEntity) {
        todo.isDone.toggle()
        do {
            try FolderCoreData.updateNumberOfActiveTodos(inFolderWithId: todo.folderId, value: todo.isDone ? -1 : 1)
            DispatchQueue.main.async {
                CoreDataManager.shared.save()
            }
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
    }
    
    func handleDelete() {
        self.alert = TodoAlert(title: "Do you really want to delete this todo?", type: .delete, message: "You can't undo this action")
        self.isAlertPresented = true
    }
    
    func deleteTodo(todo: TodoEntity) {
        do {
            try FolderCoreData.updateNumberOfActiveTodos(inFolderWithId: todo.folderId, value: -1)
            TodoCoreData.delete(todo: todo)
        } catch {
            self.alert = TodoAlert(error: error)
            self.isAlertPresented = true
        }
    }
    
    func getPriorityColor(priority: Int16) -> Color {
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
    
    func getSubtitle(deadline: Date, startDate: Date?, folderName: String?) -> String {
        var string = ""
        
        if let startDate = startDate {
            let compareResult = Calendar.current.compare(deadline, to: startDate, toGranularity: .day)
            if compareResult != .orderedSame {
                string += "\(startDate.prettyDate()) - "
            }
        }
        
        string += deadline.prettyDate()
        
        if let folderName = folderName {
            string += " • \(folderName)"
        }
        
        return string
    }
}

#Preview {
    TodoListItemView(todo: TodoCoreData.preview)
}
