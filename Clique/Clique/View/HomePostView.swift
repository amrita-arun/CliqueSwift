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

    /*
    let overallCaption: String = "my weekend in a nutshell"
    let profilePic = "person.crop.circle"
    
    private let images = ["image1",
                          "image2",
                          "image3",
                          "image4"]
    
    private let captions = ["image1",
                          "image2",
                          "image3",
                          "image4"]
     */
    let post: Post

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            /*
            HStack() {
                Image(systemName: profilePic)
                    //.resizable()
                    .font(.title2)
                Text(username)
                    .font(.title2)
                    .bold()
                Spacer()
            }
            Text(overallCaption)
                .font(.title3)
                .bold()
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(images, id: \.self) { img in
                        PhotoView(photo: img, caption: "image1")
                        /*Image(img)
                            .resizable()
                            .scaledToFill()
                            //.scaledToFill()
                            .frame(height: 250)
                            .frame(width: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                            .padding(.horizontal, 5)
                            .border(.black, width: 2)
                         */

                    }
                }
            }
           // .border(.black, width: 2)
            .frame(height: 250)
             */
            Text(username)
                .font(.title2)
                .bold()

            // Optional overall text
            Text("\(groupName) • \(post.timestamp.formatted(.dateTime.weekday().month().day()))")

            
            // Horizontal scroll of photos
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
             
            /*
            // UIKit-based swipeable carousel
            PhotoCarouselView(
                imageURLs: post.imageURLs,
                currentPage: $currentPage
            )
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Caption updates as the page changes
            Text(post.captions.indices.contains(currentPage)
                 ? post.captions[currentPage]
                 : "")
                .font(.caption)
             */
        }
        
    }
}

/*
 struct HomePostView_Previews: PreviewProvider {
 static var previews: some View {
 HomePostView()
 }
 }
 */
