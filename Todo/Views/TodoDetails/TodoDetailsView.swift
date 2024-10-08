//
//  TodoDetailsView.swift
//  Todo
//
//  Created by Nikita Sheludko on 19.08.24.
//

import SwiftUI
import CoreData

struct TodoDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var todo: TodoEntity
    @StateObject var vm: TodoDetailsViewModel
    @FetchRequest(fetchRequest: FolderEntity.getAllFetchRequest()) private var folders
    
    init(todo: TodoEntity) {
        _todo = ObservedObject(initialValue: todo)
        _vm = StateObject(wrappedValue: TodoDetailsViewModel(todo: todo, context: todo.managedObjectContext!))
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
                            Text("Low").tag(TodoEntity.Priority.low)
                            Text("Middle").tag(TodoEntity.Priority.middle)
                            Text("High").tag(TodoEntity.Priority.high)
                        }
                    }
                    HStack {
                        Image(systemName: "folder")
                        Picker("Folder", selection: $vm.todoFolder) {
                            ForEach(folders, id: \.id) { folder in
                                Text(folder.name).tag(folder)
                            }
                        }
                    }
                    TextField("Description", text: $vm.todoDescription, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
                
                Section("Actions") {
                    Button(action: {
                        vm.configAlert(.delete)
                    }, label: {
                        Text("\(Image(systemName: "trash")) Delete todo")
                            .foregroundStyle(.red)
                    })
                    Button(action: {
                        if !vm.handleSave() {
                            vm.configAlert(.invalidData)
                        } else {
                            dismiss()
                        }
                    }, label: {
                        Text("\(Image(systemName: "tray.and.arrow.down")) Save")
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
    TodoDetailsView(todo: .getPreviewTodo())
}
