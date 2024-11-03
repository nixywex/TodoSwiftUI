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
    
    var folders: [Folder]
    var callback: () async throws -> Void
    var foldersCallback: (() async throws -> Void)?
    
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
                            in: vm.todoDeadline < Date() ? vm.todoDeadline... : Date()...,
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
                    HStack {
                        Image(systemName: "folder")
                        Picker("Folder", selection: $vm.todoFolderId) {
                            ForEach(folders, id: \.id) { folder in
                                Text(folder.name).tag(folder.id)
                            }
                        }
                    }
                    TextField("Description", text: $vm.todoDescription, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
                
                Section("Actions") {
                    Button(action: {
                        Task {
                            vm.handleDelete()
                        }
                    }, label: {
                        Text("\(Image(systemName: "trash")) Delete todo")
                            .foregroundStyle(.red)
                    })
                    Button(action: {
                        Task {
                            vm.handleSave()
                            if vm.alert == nil {
                                try await callback()
                                try await foldersCallback?()
                                dismiss()
                            }
                        }
                    }, label: {
                        Text("\(Image(systemName: "tray.and.arrow.down")) Save")
                            .bold()
                    })
                }
            }
            .navigationTitle(vm.todo.text)
            .navigationBarTitleDisplayMode(.inline)
            .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
                vm.alert?.getCancelButton(cancel: { vm.alert = nil })
                if vm.alert?.type == .delete {
                    vm.alert?.getDeleteButton(delete: {
                        Task {
                            vm.deleteTodo()
                            vm.alert = nil
                            try await callback()
                            try await foldersCallback?()
                            dismiss()
                        }
                    })
                }
            } message: {
                Text(vm.alert?.message ?? "")
            }
        }
    }
}


#Preview {
    TodoDetailsView(vm: TodoDetailsViewModel(todo: PreviewExtentions.previewTodo), folders: [PreviewExtentions.previewFolder],
                    callback: PreviewExtentions.previewCallback, foldersCallback: PreviewExtentions.previewCallback)
}
