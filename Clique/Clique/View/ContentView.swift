//
//  ContentView.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import FirebaseAuth

//@available(iOS 17.0, *)
struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        VStack {
            // user is not logged in
            if userViewModel.currentUser == nil {
                SignupView(userViewModel: userViewModel)
                    //.environmentObject(userViewModel)
            } else {
                // User is logged in
                MainTabView(userViewModel: userViewModel)
                    //.environmentObject(userViewModel)
            }
        }
        .onAppear{
            userViewModel.currentUser = Auth.auth().currentUser
        }
    }
    /*
    var body: some View {
        MainTabView()
    }
     */
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
