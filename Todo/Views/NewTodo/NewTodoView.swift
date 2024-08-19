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

    @State var text: String = ""
    @State var deadline = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section ("Create a new task") {
                        TextField("New task", text: $text)
                        DatePicker(
                            "Do due",
                            selection: $deadline,
                            displayedComponents: [.date]
                        )
                    }
                }
                .scrollDisabled(true)
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
                        Button(action: {
                            withAnimation {
                                vm.addTodo(text: text, deadline: deadline)
                            }
                            dismiss()
                        }, label: {
                            Text("Add task").bold()
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
