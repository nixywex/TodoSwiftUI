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
                        do {
                            try await vm.login()
                            self.isLoginViewPresented.toggle()
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            Section("Don't have an account yet?") {
                Button("Create an account") {
                    vm.isPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $vm.isPresented) {
            SignUpView(isLoginViewPresented: $isLoginViewPresented)
        }
    }
}

#Preview {
    LoginView(isLoginViewPresented: .constant(true))
}
