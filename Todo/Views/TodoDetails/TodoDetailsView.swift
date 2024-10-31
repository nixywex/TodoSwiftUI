//
//  TodoDetailsView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI

struct TodoDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm: TodoDetailsViewModel
    
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
                    HStack {
                        Image(systemName: "calendar.badge.clock")
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
                    }
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                        DatePicker(
                            "Do due",
                            selection: $vm.todoDeadline,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Picker("Priotity", selection: $vm.todoPriority) {
                            Text("Low").tag(Todo.Priority.low)
                            Text("Middle").tag(Todo.Priority.middle)
                            Text("High").tag(Todo.Priority.high)
                        }
                    }
                    TextField("Description", text: $vm.todoDescription, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
                
                Section("Actions") {
                    Button(action: {
                        Task {
                            do {
                                try await vm.handleDelete()
                                dismiss()
                            } catch { print("Error deleting todo: \(error.localizedDescription)") }
                        }
                    }, label: {
                        Text("\(Image(systemName: "trash")) Delete todo")
                            .foregroundStyle(.red)
                    })
                    Button(action: {
                        Task {
                            if await vm.handleSave() { dismiss() }
                        }
                    }, label: {
                        Text("\(Image(systemName: "tray.and.arrow.down")) Save")
                            .bold()
                    })
                }
            }
            .navigationTitle(vm.todo.text)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    TodoDetailsView(vm: TodoDetailsViewModel(todo: PreviewExtentions.previewTodo, callback: PreviewExtentions.previewCallback,
                                             foldersCallback: PreviewExtentions.previewCallback))
}
