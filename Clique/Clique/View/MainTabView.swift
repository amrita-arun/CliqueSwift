//
//  MainTabView.swift
//  Clique
//
//  Created by Administrator on 4/17/25.
//

import SwiftUI
import Combine

struct MainTabView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var selectedTab: Int = 0

    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomePage(userViewModel: userViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            GroupsPage(userViewModel: userViewModel)
                .tabItem {
                    Label("Cliques", systemImage: "person.3")
                }
                .tag(1)
            ProfileAndCalendarPage(userViewModel: userViewModel)
                .tabItem {
                    Label("Profile",
                    systemImage: "person")
                }
                .tag(2)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .didTapDumpNotification)
            ) { _ in
                selectedTab = 1
            }
    }
}
