//
//  SignUpView.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLoginViewPresented: Bool
    
    @StateObject var vm = SignUpViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Create a new account"){
                    TextField("Name", text: $vm.name)
                    TextField("Email", text: $vm.email)
                        .autocapitalization(.none)
                    SecureField("Password", text: $vm.password)
                        .autocapitalization(.none)
                    SecureField("Confirm password", text: $vm.confirmPassword)
                        .autocapitalization(.none)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            await vm.signUp()
                            if vm.alert == nil {
                                isLoginViewPresented.toggle()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
    SignUpView(isLoginViewPresented: .constant(true))
}
