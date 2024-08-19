//
//  TodosListView.swift
//  Todo
//
//  Created by Nikita Sheludko on 18.08.24.
//

import SwiftUI

struct TodosListView: View {    
    @FetchRequest(entity: TodoEntity.entity(), sortDescriptors: [])
    private var todos: FetchedResults<TodoEntity>
    
    @State var isCurrentTodosSectionExpanded = true

    var body: some View {
        List {
            Section("Current todos", isExpanded: $isCurrentTodosSectionExpanded) {
                ForEach(todos) { todo in
                    NavigationLink(destination: {
                        //TODO: TodoDetailsView
                    }, label: {
                        HStack {
                            VStack {
                                Text(todo.text ?? "Error")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(todo.deadline?.formatted(.dateTime.day().month()) ?? "Error")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fontWeight(.light)
                            }
                        }
                    })
                }.onDelete(perform: { indexSet in
                    //TODO: handle delete action
                })
            }
        }
    }
}

#Preview {
    TodosListView()
}
