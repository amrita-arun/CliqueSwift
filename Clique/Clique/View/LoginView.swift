//
//  LoginView.swift
//  Clique
//
//  Created by Amrita Arun on 4/23/25.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var didSignIn = false
    @State private var errorMessage: String?
    @State private var showProfileSetup = false  // for Google login flow

    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Clique")
                    .font(.title)
                    .bold()
                    .padding()
                TextField("Email", text: $email)
                    .padding(15)
                    .border(Color.gray)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .padding(15)
                    .border(Color.gray)
                    .textInputAutocapitalization(.never)
                    
                
                Button("Log in") {
                    Task {
                        if (await userViewModel.signIn(with: email, password: password)) {
                            didSignIn = true
                        }
                    }
                }
                
                // Google Sign-In via a UIKit button wrapper
                GoogleSignInButtonView()
                    .frame(height: 50)
                    .padding(.horizontal)
                    .onTapGesture {
                        Task {
                            do {
                                try await userViewModel.signInWithGoogle()
                                // after Google login, go to profile setup
                                showProfileSetup = true
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                                
                // Navigate to main app on success
                // 1) Email/password goes to MainTabView
                NavigationLink(
                    "",
                    destination: MainTabView(userViewModel: userViewModel),
                    isActive: $didSignIn
                )
                // 2) Google login goes to ProfileSetupView to input username and name
                NavigationLink(
                    "",
                    destination: ProfileSetupView(userViewModel: userViewModel),
                    isActive: $showProfileSetup
                )
                
                NavigationLink("Don't have an account? Sign up") {
                    SignupView(userViewModel: userViewModel)
                }
                .navigationBarBackButtonHidden(true)
                
            }
            .padding()
        }
    }
}

struct GoogleSignInButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> GIDSignInButton {
        return GIDSignInButton()
    }
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}
