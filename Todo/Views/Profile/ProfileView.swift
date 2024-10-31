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
                        Task {
                            do {
                                try vm.signOut()
                                self.isLoginViewPresented.toggle()
                            } catch { print("Error signing out: \(error.localizedDescription)") }
                        }
                    }
                }
                
                Section {
                    Button("Delete your account") {
                        Task {
                            do {
                                try await vm.deleteAccount()
                                self.isLoginViewPresented.toggle()
                            } catch { print("Error deleteing account: \(error.localizedDescription)") }
                        }
                    }
                    .tint(.red)
                }
            }
            .navigationTitle("Profile")
        }
        .task {
            do {
                try await vm.loadCurrentUser()
            } catch {
                print("Error fetching profile: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    ProfileView(isLoginViewPresented: .constant(false))
}
