//
//  Group.swift
//  Clique
//
//  Created by Administrator on 4/17/25.
//

import Foundation

struct Group: Identifiable {
    let uuid = UUID()
    let id: String
    let name: String
    let userIds: [String]
    let uploadNow: Bool
    let created: Date
    //var lastUploaded: String
    
}
