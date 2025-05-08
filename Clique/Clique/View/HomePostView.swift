//
//  HomePostView.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import UIKit

struct HomePostView: View {
    
    let username: String
    let groupName: String       // ← add this
    @State private var currentPage: Int = 0
    let post: Post

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text(username)
                .font(.title2)
                .bold()

            Text("\(groupName) • \(post.timestamp.formatted(.dateTime.weekday().month().day()))")

            // Horizontal scroll of photos for each post
            ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(zip(post.imageURLs, post.captions)), id: \.0) { url, caption in
                    VStack {
                        AsyncImage(url: URL(string: url)) { img in
                            img
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text(caption)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 5)
            }
             
        }
        
    }
}

