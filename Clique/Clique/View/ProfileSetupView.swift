//
//  ProfileSetupView.swift
//  Clique
//
//  Created by Amrita Arun on 5/7/25.
//

import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var didCompleteSetup: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Full Name", text: $name)
                }
                Section("Username") {
                    TextField("Username", text: $username)
                }
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Set Up Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        Task {
                            do {
                                try await userViewModel.createUserProfile(name: name, username: username)
                                didCompleteSetup = true
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(name.isEmpty || username.isEmpty)
                }
            }
            // Navigate to main app on completion
            .background(
                NavigationLink(
                    destination: MainTabView(userViewModel: userViewModel),
                    isActive: $didCompleteSetup
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}
