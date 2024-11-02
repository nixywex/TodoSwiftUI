//
//  NewTodoView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct NewTodoView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm: NewTodoViewModel
    
    var callback: () async throws -> Void
    var foldersCallback: () async throws -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section ("Create a new todo") {
                        TextField("New todo", text: $vm.text)
                    }
                    
                    Section() {
                        Toggle("Start date", isOn: $vm.isStartDateOn)
                            .onChange(of: vm.isStartDateOn) {
                                vm.handleToggle()
                            }
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            DatePicker(
                                "Start date",
                                selection: Binding(get: {
                                    vm.startDate ?? Date()
                                }, set: { newValue in
                                    vm.startDate = newValue
                                }),
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                            .disabled(vm.isStartDateOn ? false : true)
                            .opacity(vm.isStartDateOn ? 1 : 0.3)
                        }
                        HStack {
                            Image(systemName: "calendar.badge.checkmark")
                            DatePicker(
                                "Deadline",
                                selection: $vm.deadline,
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                        }
                    }
                    
                    Section() {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                            Picker("Priotity", selection: $vm.priority) {
                                Text("Low").tag(Todo.Priority.low)
                                Text("Middle").tag(Todo.Priority.middle)
                                Text("High").tag(Todo.Priority.high)
                            }
                        }
                        TextField("Description", text: $vm.description, axis: .vertical)
                            .lineLimit(4, reservesSpace: true)
                    }
                }
                .scrollDisabled(true)
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                await vm.handleSaveButton()
                                if vm.alert == nil {
                                    try await callback()
                                    try await foldersCallback()
                                    dismiss()
                                }
                            }
                        }, label: {
                            Text("Add todo").bold()
                        })
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button ("Cancel") { dismiss() }
                    }
                }
            }
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

#Preview {
    NewTodoView(vm: NewTodoViewModel(folder: PreviewExtentions.previewFolder), callback: PreviewExtentions.previewCallback, foldersCallback: PreviewExtentions.previewCallback)
}
