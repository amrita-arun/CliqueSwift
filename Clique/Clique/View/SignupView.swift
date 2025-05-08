//
//  SignupView.swift
//  Clique
//
//  Created by Amrita Arun on 4/23/25.
//

import SwiftUI

struct SignupView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var didSignUp = false
    @State private var errorMessage: String?

    
    @State var email: String = ""
    @State var password: String = ""
    @State var name: String = ""
    @State var username: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Clique")
                    .font(.title)
                    .bold()
                    .padding()
                TextField("Name", text: $name)
                    .padding(15)
                    .border(Color.gray)
                TextField("Username", text: $username)
                    .padding(15)
                    .border(Color.gray)
                    .textInputAutocapitalization(.never)
                TextField("Email", text: $email)
                    .padding(15)
                    .border(Color.gray)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .padding(15)
                    .border(Color.gray)
                    .textInputAutocapitalization(.never)
                Button("Sign up") {
                    Task {
                        await userViewModel.signUp(with: email, name: name, password: password, username: username)
                        
                        didSignUp = true
                    }
                }
                
                NavigationLink("Have an account? Log in") {
                    LoginView(userViewModel: userViewModel)
                }
                .navigationBarBackButtonHidden(true)
                
            }
            
            .padding()
        }
        
        
    }
}
