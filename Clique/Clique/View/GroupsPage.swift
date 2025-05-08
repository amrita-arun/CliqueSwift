//
//  GroupsPage.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import UserNotifications    // ← add this at the top

struct GroupsPage: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var postVM = PostViewModel()


    @State private var showAddGroup = false
    @State private var selectedGroup: Group?
    @State private var hasUploaded: [String: Bool] = [:]


    var body: some View {
        NavigationStack {
            VStack {
                ForEach(userViewModel.groups, id: \.id) { group in
                    // compute whether they can upload
                    let uploaded = hasUploaded[group.id] ?? false
                    GroupBox(
                        group: group,
                        canUpload: !uploaded   // disable if already uploaded
                    ) {
                        selectedGroup = group
                    }
                }
                Spacer()
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showAddGroup = true } label: {
                        Image(systemName: "plus")
                    }
                    
                    Button { scheduleTestNotification() } label: {
                        Image(systemName: "bell")
                    }
                }
                    
            }
        }
            .sheet(isPresented: $showAddGroup) {
                AddGroupView(userViewModel: userViewModel)
            }
            // present UploadDumpView whenever `selectedGroup` is non‐nil
            .sheet(item: $selectedGroup) { group in
                UploadDump(
                    postViewModel: PostViewModel(),
                    userViewModel: userViewModel,
                    currentGroupID: group.id
                )
            }
            .task {
                await userViewModel.fetchGroups()
                for group in userViewModel.groups {
                    do {
                        let didUpload = try await postVM.hasUploadedThisWeek(groupID: group.id)
                        hasUploaded[group.id] = didUpload
                    } catch {
                        hasUploaded[group.id] = false
                    }
                }
            }
        }
    
    private func scheduleTestNotification() {
        let center = UNUserNotificationCenter.current()
        // build a quick notification in 5 seconds
        let content = UNMutableNotificationContent()
        content.title = "Upload Time!"
        content.body  = "It's time to upload your photo dump!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let req = UNNotificationRequest(
            identifier: "testDumpReminder",
            content: content,
            trigger: trigger
        )
        center.add(req)
    }
}


struct GroupBox: View {
    let group: Group
    let canUpload: Bool
    let onUpload: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(group.name).font(.headline)
                Spacer()
                Button("Upload Dump") {
                    onUpload()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canUpload)
                .opacity(canUpload ? 1 : 0.5)
            }
            .padding()
            Divider()
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

/*
 struct GroupsPage_Previews: PreviewProvider {
 static var previews: some View {
 GroupsPage()
 }
 }
 */
