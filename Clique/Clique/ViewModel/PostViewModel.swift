//
//  PostViewModel.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore


class PostViewModel: ObservableObject {
    private let storageRef = Storage.storage().reference()
    private let db = Firestore.firestore()

    @Published var images: [UIImage] = []
    @Published var captions: [String] = []

    func uploadDump(groupID: String, imgs: [UIImage], captions: [String]) async throws {
        images = imgs
        self.captions = captions
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain:"PostVM", code:1, userInfo:[NSLocalizedDescriptionKey:"No authenticated user"])
        }
        guard !images.isEmpty else {
            throw NSError(domain:"PostVM", code:2, userInfo:[NSLocalizedDescriptionKey:"No images to upload"])
        }

        // generate dumpID and base storage ref
        let dumpID  = UUID().uuidString
        let baseRef = storageRef
                    .child("user_dumps")
                    .child(uid)
                    .child(groupID)
                    .child(dumpID)

        // upload each image in turn
        var downloadURLs = [String]()
        for (i, uiImage) in images.enumerated() {
            guard let data = uiImage.jpegData(compressionQuality: 0.8) else {
                throw NSError(domain:"PostVM", code:3,
                              userInfo:[NSLocalizedDescriptionKey:"JPEG failed"])
            }
            let imgRef = baseRef.child("image_\(i).jpg")
            let meta   = StorageMetadata()
            meta.contentType = "image/jpeg"

            _ = try await imgRef.putDataAsync(data, metadata: meta)
            let url = try await imgRef.downloadURLAsync()
            downloadURLs.append(url.absoluteString)
        }

        // write metadata to Firestore
        let dumpData: [String:Any] = [
            "userID":    uid,
            "groupID":   groupID,
            "dumpID":    dumpID,
            "imageURLs": downloadURLs,
            "captions":  captions,
            "timestamp": Timestamp(date: Date())
        ]
        try await db
            .collection("dumps")
            .document(dumpID)
            .setData(dumpData)
    }
    
    // Returns true if the current user has already uploaded a dump this week
    func hasUploadedThisWeek(groupID: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
    
        // calculate the most recent Sunday 9 AM
        let calendar = Calendar.current
        let now = Date()
        var comps = DateComponents()
        comps.weekday = 1  // Sunday
        comps.hour    = 9
        comps.minute  = 0
        comps.second  = 0
        let start = calendar.nextDate(
          after: now,
          matching: comps,
          matchingPolicy: .nextTimePreservingSmallerComponents,
          direction: .backward
       ) ?? now // from StackOverflow
    
        // query for any dump in that window. look in dumps collection for documents where userID matches the current user, group ID matches the group in question, and timestamp >= start (aka uploaded since that Sunday). all we need to know is that at least 1 exists, so we limit to 1
        let snap = try await db
          .collection("dumps")
          .whereField("userID",  isEqualTo: uid)
          .whereField("groupID", isEqualTo: groupID)
          .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
          .limit(to: 1)
          .getDocuments()
    
        return !snap.documents.isEmpty // return true if a document has been found
      }
}
    
// From StackOverflow
extension StorageReference {
    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { cont in
            self.putData(data, metadata: metadata) { m, e in
                if let e = e    { cont.resume(throwing: e) }
                else if let m = m { cont.resume(returning: m) }
            }
        }
    }
    func downloadURLAsync() async throws -> URL {
        try await withCheckedThrowingContinuation { cont in
            self.downloadURL { url, e in
                if let e = e    { cont.resume(throwing: e) }
                else if let url = url { cont.resume(returning: url) }
            }
        }
    }
}
    
    
    
    
