//
//  FeedViewModel.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var usernamesById: [String: String] = [:]
        
    private let db = Firestore.firestore()
    private let userViewModel: UserViewModel
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    func fetchPosts() async {
        // ensure we have group IDs
        let groupIds = userViewModel.groupIds
        guard !groupIds.isEmpty else {
            self.posts = []
            return
        }
            
        do {
            let snap = try await db
                .collection("dumps")
                .whereField("groupID", in: groupIds)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            
            let loaded = snap.documents.map { doc in
                let d = doc.data()
                return Post(
                    id:       doc.documentID,
                    userID:   d["userID"] as? String ?? "",
                    groupID:  d["groupID"] as? String ?? "",
                    imageURLs: d["imageURLs"] as? [String] ?? [],
                    captions: d["captions"]  as? [String] ?? [],
                    timestamp:(d["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
                
            self.posts = loaded
            
            let uniqueUserIDs = Set(loaded.map(\.userID))
            await fetchUsernames(for: Array(uniqueUserIDs))

        } catch {
            print("failed fetching posts:", error)
        }
    }
    
    // Fetches dumps in the user’s groups for the exact selected day
    func fetchPosts(on date: Date) async {
        let groupIds = userViewModel.groupIds
        guard !groupIds.isEmpty else {
            self.posts = []
            return
        }

        // build the start and end timestamps for that day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            self.posts = []
            return
        }
   
        do {
            let snap = try await db
                .collection("dumps")
                .whereField("groupID", in: groupIds)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                .whereField("timestamp", isLessThan: Timestamp(date: nextDay))
                .order(by: "timestamp", descending: true)
                .getDocuments()

            let loaded = snap.documents.map { doc in
                let d = doc.data()
                return Post(
                    id:        doc.documentID,
                    userID:    d["userID"]   as? String   ?? "",
                    groupID:   d["groupID"]  as? String   ?? "",
                    imageURLs: d["imageURLs"]as? [String] ?? [],
                    captions:  d["captions"] as? [String] ?? [],
                    timestamp: (d["timestamp"] as? Timestamp)?.dateValue() ?? Date()
               )
            }
            self.posts = loaded
            // fetch missing usernames
            let uids = Set(loaded.map(\.userID))
            await fetchUsernames(for: Array(uids))
        } catch {
            print("fetchPosts(on:) failed:", error)
            self.posts = []
        }
    }

    // Fetch and cache usernames for any IDs not yet loaded
    private func fetchUsernames(for userIDs: [String]) async {
        for uid in userIDs {
            // skip if already cached
            if usernamesById[uid] != nil { continue }
            do {
                let doc = try await db.collection("users").document(uid).getDocument()
                let username = (doc.data()?["username"] as? String) ?? "Unknown"
                usernamesById[uid] = username
            } catch {
                print("failed fetching username for \(uid):", error)
                usernamesById[uid] = "Unknown"
            }
        }
    }
}
