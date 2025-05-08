//
//  SignupView.swift
//  Clique
//
//  Created by Amrita Arun on 4/23/25.
//

import SwiftUI

//@available(iOS 17.0, *)
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
                    
                /*
                NavigationLink {
                    MainTabView()
                        //.navigationBarBackButtonHidden(true)
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(width: 90, height: 35)
                        .background(Color.gray)
                        .cornerRadius(5)
                        .padding()
                }
                 */
                
                /*
                Button("Sign Up") {
                    Task {
                        do {
                            try await userViewModel.signUp(with: email, password: password)
                            // once currentUser is non‐nil, consider sign up successful
                            if userViewModel.currentUser != nil {
                                didSignUp = true
                            }
                        } catch {
                            // surface any error to the user
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .font(.headline)
                .frame(width: 120, height: 44)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                 */

                // hidden link — only activates when didSignUp becomes true
                //NavigationLink("", destination: MainTabView(), isActive: $didSignUp)
                // Hidden NavigationLink bound to didSignUp
                /*
                NavigationLink(
                    destination: MainTabView(),
                    isActive: $didSignUp,
                    label: { EmptyView() }
                )
                 */

                
                NavigationLink("Have an account? Log in") {
                    LoginView(userViewModel: userViewModel)
                }
                .navigationBarBackButtonHidden(true)
                
            }
            /*
            .navigationDestination(isPresented: $didSignUp) {
                MainTabView(userViewModel: userViewModel)
            }
            .navigationBarBackButtonHidden(true)
             */
            .padding()
        }
        
        
    }
}

/*
 #Preview {
 if #available(iOS 17.0, *) {
 SignupView()
 } else {
 // Fallback on earlier versions
 }
 }
 */
