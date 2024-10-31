//
//  HomeView.swift
//  Todo
//
//  Created by Nikita Sheludko on 16.09.24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            GroupBox("Overview") {
                Text("This functionality is not available yet.")
                    .padding()
                
                Text("\(Image(systemName: "exclamationmark.circle")) Overview shows the top 5 most pressing todos to complete based on priority and deadline.")
                    .font(.system(.caption))
                    .foregroundStyle(.gray)
            }
            .padding()
            .navigationTitle("Home")
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
