//
//  PhotoView.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI

struct PhotoView: View {
    let photo: String
    let caption: String
    
    var body: some View {
        Image(photo)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 250)
            .frame(width: 250)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .padding(.horizontal, 5)
            //.border(.black, width: 2)
            .overlay(Caption(imgcaption: caption), alignment: .bottomLeading)
    }
}

struct Caption: View {
    let imgcaption: String
    
    var body: some View {
        Text("\(imgcaption)")
            .font(.body)
            .foregroundColor(.white)
            .padding(10)
            .padding(.trailing, 5)
            .background(Color.black)
            .opacity(0.75)
            .cornerRadius(5)
            .padding(.leading, 5)
        /*
        VStack {
            Text(imgcaption)
                .font(.caption)
                .foregroundColor(.white)
                .padding(10)
        }
        .background(Color.black)
                .opacity(0.8)
                .cornerRadius(5.0)
                .padding(.leading, 5)
         */
        
    }
}

/*
 struct PhotoView_Previews: PreviewProvider {
 static var previews: some View {
 PhotoView()
 }
 }
 */
