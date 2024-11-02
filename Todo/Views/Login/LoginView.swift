//
//  LoginView.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoginViewPresented: Bool
    @StateObject var vm = LoginViewModel()
    
    var body: some View {
        List {
            Section("Login in to your account"){
                TextField("Email", text: $vm.email)
                    .autocapitalization(.none)
                SecureField("Password", text: $vm.password)
                    .autocapitalization(.none)
                Button("Login") {
                    Task {
                        await vm.login()
                        if vm.alert == nil {
                            isLoginViewPresented.toggle()
                        }
                    }
                }
            }
            
            Section("Don't have an account yet?") {
                Button("Create an account") {
                    vm.isSingUpPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $vm.isSingUpPresented) {
            SignUpView(isLoginViewPresented: $isLoginViewPresented)
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}

#Preview {
    LoginView(isLoginViewPresented: .constant(true))
}
