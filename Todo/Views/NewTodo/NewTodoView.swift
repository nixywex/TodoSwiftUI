//
//  NewTodoView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct NewTodoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: NewTodoViewModel

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section ("Create a new todo") {
                        TextField("New todo", text: $vm.text)
                        DatePicker(
                            "Do due",
                            selection: $vm.deadline,
                            displayedComponents: [.date]
                        )
                    }
                }
                .scrollDisabled(true)
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
                        Button(action: {
                            withAnimation {
                                vm.addTodo(text: vm.text, deadline: vm.deadline)
                            }
                            dismiss()
                        }, label: {
                            Text("Add todo").bold()
                        })
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button ("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    NewTodoView(vm: .init(provider: .shared))
}
