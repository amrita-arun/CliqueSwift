//
//  GroupsPage.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI

struct GroupsPage: View {
    let groups: [Group] = [
        Group(name: "Family", users: [
            User(name: "Anita", username: "anirang"),
            User(name: "Arun", username: "arunsrini"),
            User(name: "Ananth", username: "anantharun")], uploadNow: true),
        Group(name: "Besties", users: [
            User(name: "Shruti", username: "shruti"),
            User(name: "Aditi", username: "aditi"),
            User(name: "Namrata", username: "namrata")], uploadNow: false)
    ]
        
    var body: some View {
        VStack(alignment: .leading) {
            Text("Groups")
                .font(.title)
                .bold()
                .padding(.leading, 15)
            ForEach(groups) { group in
                GroupBox(group: group)
            }
            Spacer()
            
        }
        
        
    }
    
}

struct GroupBox: View {
    let group: Group
    //let uploadNow: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                HStack {
                    Text("Just now")
                    Spacer()
                }
                
                Text(group.name)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            //.border(Color.black)
            Spacer()
            
            HStack {
                Label("Upload dump", systemImage: "clock")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.trailing, 5)
                    .background(.purple.opacity(0.75), in: Capsule())
                
            }
            .padding(10)
            .opacity(group.uploadNow ? 100.0 : 0.0)
            //.border(Color.black)
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .background(Color.gray)
        .cornerRadius(10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .padding(.bottom, 15)
        //.border(Color.black)
        
        
    }
    
}

struct GroupsPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupsPage()
    }
}
