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
                    TextField("Enter your todo", text: $vm.todoText)
                    Toggle("Is done", isOn: $vm.isTodoDone)
                }
                
                Section {
                    Toggle("Start date", isOn: $vm.isStartDateOn)
                        .onChange(of: vm.isStartDateOn) {
                            vm.handleToggle()
                        }
                    DatePicker(
                        "Start date",
                        selection: Binding(get: {
                            vm.todoStartDate ?? Date()
                        }, set: { newValue in
                            vm.todoStartDate = newValue
                        }),
                        in: ...vm.todoDeadline,
                        displayedComponents: [.date]
                    )
                    .disabled(vm.isStartDateOn ? false : true)
                    .opacity(vm.isStartDateOn ? 1 : 0.3)
                    DatePicker(
                        "Do due",
                        selection: $vm.todoDeadline,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                }
                
                Section {
                    TextField("Description", text: $vm.todoDescription, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
                
                Section("Actions") {
                    Button(action: {
                        vm.configAlert(.delete)
                    }, label: {
                        Text("Delete todo")
                            .foregroundStyle(.red)
                    })
                    Button(action: {
                        if !vm.handleSave() {
                            vm.configAlert(.invaidData)
                        } else {
                            dismiss()
                        }
                    }, label: {
                        Text("Save")
                            .bold()
                    })
                }
            }
            .navigationTitle(todo.text)
            .navigationBarTitleDisplayMode(.inline)
            .alert(vm.alertHeader, isPresented: $vm.isAlertShowed) {
                Button(vm.alertType == .delete ? "Cancel" : "OK", role: .cancel) {}
                if vm.alertType == .delete {
                    Button("Delete", role: .destructive) {
                        vm.handleDelete(todo: todo)
                        dismiss()
                    }
                }
            } message: {
                Text(vm.alertText)
            }
        }
    }
}


#Preview {
    TodoDetailsView(todo: .getPreviewTodo(), provider: .preview)
}
