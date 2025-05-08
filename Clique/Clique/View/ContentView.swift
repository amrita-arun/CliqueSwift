//
//  ContentView.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        VStack {
            // user is not logged in
            if userViewModel.currentUser == nil {
                SignupView(userViewModel: userViewModel)
            } else {
                MainTabView(userViewModel: userViewModel)
            }
        }
        .onAppear{
            userViewModel.currentUser = Auth.auth().currentUser
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            ContentView()
        } else {
            // Fallback on earlier versions
        }
    }
}
