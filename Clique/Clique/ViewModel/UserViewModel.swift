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


@MainActor
class UserViewModel: ObservableObject {
    
    private let auth = Auth.auth()
    private let db   = Firestore.firestore()
    var groupIds: [String] = []
    
    @Published var groups: [Group] = []
    @Published var currentUser : User?
    @Published var user: CliqueUser?
    
    init() {
        if let user = auth.currentUser {
            currentUser = user
            Task { await fetchCurrentUserProfile() }
        }
    }
    
    // Writes a Firestore document in `/users/{uid}` after Google sign-in
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
       
       // Update local user
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

            // Prepare Firestore data
            let userData: [String: Any] = [
                "email":    email,
                "name":     name,
                "username": username,
                "groupIds": groupIds
            ]

            // Write to Firestore under "users/{uid}"
            try await db
                .collection("users")
                .document(uid)
                .setData(userData)
            
            print("User document created for \(uid)")

        } catch {
            print(error)
            
            print("Error signing up or writing user data: \(error)")

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
        // Make a new group document
        let groupRef = db.collection("groups").document()
        let groupID  = groupRef.documentID
        let groupData: [String:Any] = [
            "name":    name,
            "userIds": memberUIDs,
            "created": Timestamp(date: Date())
        ]
        try await groupRef.setData(groupData)

        // Add this groupID to each user's `groupIds` field
        for uid in memberUIDs {
            let userRef = db.collection("users").document(uid)
            try await userRef.updateData([
                "groupIds": FieldValue.arrayUnion([groupID])
            ])
        }

        groupIds.append(groupID)
    }
    
    func fetchGroups() async {
        guard let uid = currentUser?.uid else { return }
        
        do {
            // Load the user's document to get their groupIds
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
            
            // Query the 'groups' collection by document ID
            let snap = try await db
                .collection("groups")
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments()
            
            // Map documents into 'Group' models
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
            } // updates user on main thread (DispatchQueue handles UI work, and does not run on the background thread like Firestore work. async so it's scheduled if main thread is currently busy. then the UI on CalendarAndProfileView refreshes so that the user's username is displayed there (from StackOverflow)
        } catch {
            print("fetchCurrentUserProfile failed:", error)
        }
    }
    
    // Sign in with Google and authenticate to Firebase
    func signInWithGoogle() async throws {
        
        // Get Firebase clientID from GoogleService-Info.plist and set up Google configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "UserVM", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing clientID"])
            }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
            // Find a UIViewController to present from (the root VC of the key window). The Google Sign In provider requires a UIViewController to display the Google sign in sheet
            guard let scene = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let rootVC = scene.windows.first(where: \.isKeyWindow)?.rootViewController // from StackOverflow + ChatGPT
            else {
                throw NSError(domain: "UserVM", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "No active view controller"])
        }
        
                
        // Perform the async sign-in, when the user finished, we are returned the GIDGoogleUser with ID and access tokens
        let userAuth = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        // Extract ID token and access tokens to pass to Firebase
        guard let idTokenString = userAuth.user.idToken?.tokenString else {
            throw NSError(domain: "UserVM", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Google ID token missing"])
        }
        let accessTokenString = userAuth.user.accessToken.tokenString
        
        // Exchange for Firebase credential & sign in
        let credential = GoogleAuthProvider.credential(
            withIDToken: idTokenString,
            accessToken: accessTokenString
        )
        let result = try await auth.signIn(with: credential)
        currentUser = result.user
        // Load Firestore profile
        await fetchCurrentUserProfile()
    }
}
