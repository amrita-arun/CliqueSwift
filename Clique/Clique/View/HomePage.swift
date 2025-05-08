//
//  HomePage.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI

struct HomePage: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var feedViewModel: FeedViewModel

    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        _feedViewModel = StateObject(wrappedValue: FeedViewModel(userViewModel: userViewModel))
    }
    
    var body: some View {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(feedViewModel.posts) { post in
                        // look up the group's name from already‐fetched groups
                        let groupName = userViewModel
                            .groups
                            .first(where: { $0.id == post.groupID })?
                            .name
                        ?? "Group"
        
                        HomePostView(
                            username:  feedViewModel.usernamesById[post.userID] ?? "Unknown",
                            groupName: groupName,
                            post:      post
                        )
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Clique")
            .task {
                // ensure we have the latest group IDs
                await userViewModel.fetchGroups()
                // then fetch posts for those groups
                await feedViewModel.fetchPosts()
            }
    }
}

