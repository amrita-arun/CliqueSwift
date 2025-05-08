//
//  UploadPhotoView.swift
//  Clique
//
//  Created by Amrita Arun on 4/26/25.
//

import SwiftUI

struct UploadPhotoView: View {
    @ObservedObject var postViewModel: PostViewModel
    var img: Image
    @Binding var caption: String
    //var captionNum: Int
    
    var body: some View {
        img
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
        TextField("Caption", text: $caption)
            .padding()
        
    }
}

/*
 #Preview {
 UploadPhotoView()
 }
 */
