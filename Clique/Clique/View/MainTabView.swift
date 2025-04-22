//
//  MainTabView.swift
//  Clique
//
//  Created by Administrator on 4/17/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            GroupsPage()
                .tabItem {
                    Label("Cliques", systemImage: "person.3")
                }
            ProfileAndCalendarPage()
                .tabItem {
                    Label("Profile",
                    systemImage: "person")
                }
            
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
