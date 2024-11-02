//
//  ProfileView.swift
//  Todo
//
//  Created by Nikita Sheludko on 25.10.24.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isLoginViewPresented: Bool
    
    @StateObject var vm = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let user = vm.user {
                        Text("Hello, \(user.name)")
                        Text("Your id: \(user.userId)")
                        Text("Your email: \(user.email)")
                        Text("Your are hier since: \(user.dateCreated?.prettyDateWithYear() ?? "Unknown")")
                    } else {
                        Text("Loading...")
                    }
                    
                    Button("Sign out") {
                        vm.signOut()
                        self.isLoginViewPresented.toggle()
                    }
                }
                
                Section {
                    Button("Delete your account") {
                        Task {
                            vm.handleDelete()
                        }
                        
                    }
                    .tint(.red)
                }
            }
            .navigationTitle("Profile")
        }
        .task {
            await vm.loadCurrentUser()
        }
        .alert(vm.alert?.title ?? "Warning", isPresented: $vm.isAlertPresented) {
            vm.alert?.getCancelButton(cancel: { vm.alert = nil })
            if vm.alert?.type == .delete {
                vm.alert?.getDeleteButton(delete: {
                    Task {
                        await vm.deleteAccount()
                        vm.alert = nil
                        isLoginViewPresented = true
                    }
                })
            }
        } message: {
            Text(vm.alert?.message ?? "")
        }
    }
}


#Preview {
    ProfileView(isLoginViewPresented: .constant(false))
}
