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
    private let storageRef = Storage.storage().reference()   // ← root reference
    private let db = Firestore.firestore()

    @Published var caption1: String = ""
    @Published var caption2: String = ""
    @Published var caption3: String = ""
    @Published var caption4: String = ""
    @Published var caption5: String = ""
    
    @Published var images: [UIImage] = []
    @Published var captions: [String] = []
    
   // init() {
        //self.captions = ["", "", "", "", ""]
   // }
    
    func addCaption(capNum: Int, caption: String) -> Bool {
        if (capNum == 1) {
            caption1 = caption
        } else if (capNum == 2) {
            caption2 = caption
        } else if (capNum == 3) {
            caption3 = caption
        } else if (capNum == 4) {
            caption4 = caption
        } else if (capNum == 5) {
            caption5 = caption
        } else {
            return false
        }
        return true
    }
    
    func uploadPost() async -> Bool {
        //let storageRef = storage.reference()
        //let imagesRef = storageRef.child("users")
        

        return true
    }
    
    /*
    func addPhotos(images: [Image]) -> Bool {
        self.images.append(contentsOf: images)
        return true
    }
     */
    
    func uploadDump(groupID: String, imgs: [UIImage], captions: [String]) async throws {
        images = imgs
        self.captions = captions
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain:"PostVM", code:1, userInfo:[NSLocalizedDescriptionKey:"No authenticated user"])
        }
        guard !images.isEmpty else {
            throw NSError(domain:"PostVM", code:2, userInfo:[NSLocalizedDescriptionKey:"No images to upload"])
        }

        // 1) generate dumpID and base storage ref
        let dumpID  = UUID().uuidString
        let baseRef = storageRef
                    .child("user_dumps")
                    .child(uid)
                    .child(groupID)
                    .child(dumpID)

        // 2) upload each image in turn
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

        // 3) Optionally write metadata to Firestore
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
    
    /// Returns true if the current user has already uploaded a dump
      /// in `groupID` since last Sunday at 9 AM.
    func hasUploadedThisWeek(groupID: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
    
        // 1) calculate the most recent Sunday 9 AM
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
       ) ?? now
    
        // 2) query for any dump in that window
        let snap = try await db
          .collection("dumps")
          .whereField("userID",  isEqualTo: uid)
          .whereField("groupID", isEqualTo: groupID)
          .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
          .limit(to: 1)
          .getDocuments()
    
        return !snap.documents.isEmpty
      }
}
    
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
    
    
    
    
