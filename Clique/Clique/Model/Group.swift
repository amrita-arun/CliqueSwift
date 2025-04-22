//
//  Group.swift
//  Clique
//
//  Created by Administrator on 4/17/25.
//

import Foundation

struct Group: Identifiable {
    let id = UUID()
    let name: String
    let users: [User]
    let uploadNow: Bool
    //var lastUploaded: String
    
}
