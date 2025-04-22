//
//  User.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import Foundation

struct User: Identifiable {
    let id = UUID()
    let name: String
    let username: String
}
