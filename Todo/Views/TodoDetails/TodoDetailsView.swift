//
//  TodoDetailsView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI

struct TodoDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    let provider: PersistenceController
    
    @ObservedObject var todo: TodoEntity
    @ObservedObject var vm: TodoDetailsViewModel
    
    init(todo: TodoEntity, provider: PersistenceController) {
        self.todo = todo
        self.provider = provider
        self.vm = TodoDetailsViewModel(todo: todo, provider: provider)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section ("Edit your todo") {
                    TextField("Enter your todo", text: $todo.text)
                    DatePicker(
                        "Do due",
                        selection: $todo.deadline,
                        displayedComponents: [.date]
                    )
                    Toggle("Is done", isOn: $todo.isDone)
                }
                Section("Actions") {
                    Button(action: {
                        vm.isAlertShowed.toggle()
                    }, label: {
                        Text("Delete todo").foregroundStyle(.red)
                    })
                    Button(action: {
                        vm.handleSave()
                        dismiss()
                    }, label: {
                        Text("Save").bold()
                    })
                }
            }
            .navigationTitle(todo.text)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Are you sure you want to delete a todo?", isPresented: $vm.isAlertShowed) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    vm.handleDelete(todo: todo)
                    dismiss()
                }
            } message: {
                Text("The todo cannot be restored")
            }
        }
    }
}


#Preview {
    TodoDetailsView(todo: .getPreviewTodo(), provider: .preview)
}
