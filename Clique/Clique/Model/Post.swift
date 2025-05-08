//
//  Post.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import Foundation

struct Post: Identifiable {
    let id: String
    let userID: String
    let groupID: String        

    let imageURLs: [String]
    let captions: [String]
    let timestamp: Date
    
}
