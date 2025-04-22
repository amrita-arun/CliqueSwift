//
//  HomePage.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI

struct HomePage: View {
    let numPosts: Int = 5
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(1..<5) {_ in
                    HomePostView()
                }
                .padding(20)
            }
        }
        .navigationTitle("Clique")
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
