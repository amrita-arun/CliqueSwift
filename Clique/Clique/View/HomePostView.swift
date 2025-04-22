//
//  HomePostView.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI

struct HomePostView: View {
    let username: String = "amritaarun"
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            
        }
        
    }
}

struct HomePostView_Previews: PreviewProvider {
    static var previews: some View {
        HomePostView()
    }
}
