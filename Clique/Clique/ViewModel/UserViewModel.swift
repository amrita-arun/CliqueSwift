//
//  UserViewModel.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignInSwift
import FirebaseCore
import GoogleSignIn

//@available(iOS 17.0, *)
//@Observable
@MainActor
class UserViewModel: ObservableObject {
    
    private let auth = Auth.auth()
    private let db   = Firestore.firestore()
    
    var groupIds: [String] = []
    @Published var groups: [Group] = []
    
    @Published var currentUser : User?
    @Published var user: CliqueUser?
    
    /// Writes a Firestore document in `/users/{uid}` after Google sign-in,
       /// initializing name, username, email, and an empty groupIds array.
   func createUserProfile(name: String, username: String) async throws {
       guard let uid = currentUser?.uid,
             let email = currentUser?.email
       else {
           throw NSError(
               domain: "UserVM",
               code: 0,
               userInfo: [NSLocalizedDescriptionKey: "Missing authenticated user or email"]
           )
       }
       let data: [String:Any] = [
           "name": name,
           "username": username,
           "email": email,
           "groupIds": []
       ]
       // Create the Firestore user document
       try await db.collection("users")
                   .document(uid)
                   .setData(data)
       // Update local cache
       self.user = CliqueUser(id: uid, name: name, username: username)
   }
    
    func signUp(with email: String, name: String, password: String, username: String) async {
        do {
            let result = try await auth.createUser(
                withEmail: email,
                password: password
            )

            currentUser = result.user
            let uid = result.user.uid

            // 2. Prepare Firestore data
            let userData: [String: Any] = [
                "email":    email,
                "name":     name,
                "username": username,
                "groupIds": groupIds
            ]

            // 3. Write to Firestore under "users/{uid}"
            try await db
                .collection("users")
                .document(uid)
                .setData(userData)
            
            print("✅ User document created for \(uid)")

        } catch {
            print(error)
            
            print("❌ Error signing up or writing user data: \(error)")

        }
        
    }

    func signIn(with email: String, password: String) async -> Bool {
        do {
            let result = try await auth.signIn(
                withEmail: email,
                password: password
            )
            currentUser = result.user
            await fetchCurrentUserProfile()

            print(currentUser)
            return true
        } catch {
            print(error)
        }
        return false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("signed out")
        } catch {
            print("error singing out: \(error)")
        }
        currentUser = nil
    }
    
    func fetchUser(byEmail email: String) async throws -> CliqueUser? {
            let snap = try await db
                .collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments()
        guard let doc = snap.documents.first else { return nil }
        let data = doc.data()
        let name     = data["name"] as? String     ?? ""
        let username = data["username"] as? String ?? ""
        return CliqueUser(id: doc.documentID, name: name, username: username)
    }

    func createGroup(name: String, memberUIDs: [String]) async throws {
        // 1. Make a new group document
        let groupRef = db.collection("groups").document()
        let groupID  = groupRef.documentID
        let groupData: [String:Any] = [
            "name":    name,
            "userIds": memberUIDs,
            "created": Timestamp(date: Date())
        ]
        try await groupRef.setData(groupData)

        // 2. Add this groupID to each user's `groupIds` field
        for uid in memberUIDs {
            let userRef = db.collection("users").document(uid)
            try await userRef.updateData([
                "groupIds": FieldValue.arrayUnion([groupID])
            ])
        }

        // 3. Keep local state in sync
        groupIds.append(groupID)
    }
    
    func fetchGroups() async {
        guard let uid = currentUser?.uid else { return }
        
        do {
            // 1. Load the user's document to get their groupIds
            let userDoc = try await db
                .collection("users")
                .document(uid)
                .getDocument()
            let data = userDoc.data() ?? [:]
            let ids  = data["groupIds"] as? [String] ?? []
            self.groupIds = ids
            
            guard !ids.isEmpty else {
                self.groups = []
                return
            }
            
            // 2. Query the `groups` collection by document ID
            let snap = try await db
                .collection("groups")
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments()
            
            // 3. Map documents into `Group` models
            self.groups = snap.documents.map { doc in
                let d = doc.data()
                let name    = d["name"] as? String     ?? ""
                let userIds = d["userIds"] as? [String] ?? []
                let created = (d["created"] as? Timestamp)?
                    .dateValue() ?? Date()
                return Group(
                    id: doc.documentID,
                    name: name,
                    userIds: userIds,
                    uploadNow: true, created: created
                )
            }
        } catch {
            print("Error fetching groups: \(error)")
        }
    }
    
    func fetchCurrentUserProfile() async {
        guard let uid = currentUser?.uid else { return }
        do {
            let snap = try await db
                .collection("users")
                .document(uid)
                .getDocument()
            guard let data = snap.data() else { return }
            let name     = data["name"]     as? String ?? ""
            let username = data["username"] as? String ?? ""
            DispatchQueue.main.async {
                self.user = CliqueUser(id: uid, name: name, username: username)
            }
        } catch {
            print("⚠️ fetchCurrentUserProfile failed:", error)
        }
    }
    
    /// Sign in with Google and authenticate to Firebase
    func signInWithGoogle() async throws {
        // 1) Get Firebase client ID
        // 1) Get Firebase clientID and set up Google configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "UserVM", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing clientID"])
            }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
                // 2) Find a UIViewController to present from (the root VC of the key window)
            guard let scene = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let rootVC = scene.windows.first(where: \.isKeyWindow)?.rootViewController
            else {
                throw NSError(domain: "UserVM", code: 1,
                                 userInfo: [NSLocalizedDescriptionKey: "No active view controller"])
        }
        
                // Extract tokens from the authentication object
        // 3) Perform the async sign-in, passing the presenter
        let userAuth = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        // 4) Extract token strings
        // idToken is optional GIDToken? → extract its tokenString
        guard let idTokenString = userAuth.user.idToken?.tokenString else {
            throw NSError(domain: "UserVM", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Google ID token missing"])
        }
        // accessToken is a non-optional GIDToken → get its tokenString
        let accessTokenString = userAuth.user.accessToken.tokenString
        
        // 5) Exchange for Firebase credential & sign in
        let credential = GoogleAuthProvider.credential(
            withIDToken: idTokenString,
            accessToken: accessTokenString
        )
        let result = try await auth.signIn(with: credential)
        currentUser = result.user
        // 5) Load Firestore profile
        await fetchCurrentUserProfile()
    }
}
