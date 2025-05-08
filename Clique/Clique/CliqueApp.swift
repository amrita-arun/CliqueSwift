//
//  CliqueApp.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import GoogleSignIn
import GoogleSignInSwift

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
      UNUserNotificationCenter.current().delegate = self
      scheduleWeeklyReminder()
      //return GIDSignIn.sharedInstance.handle(url)
      guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing Firebase clientID")
          }
          GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

          return true
    //return true
  }
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
      ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
      }
    
    private func scheduleWeeklyReminder() {
        let center = UNUserNotificationCenter.current()
        // 1) Request permission
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else { return }
         // 2) Build the content
            let content = UNMutableNotificationContent()
            content.title = "📸 Time to dump your week!"
            content.body  = "Share 5 photos from your past week with your Clique."
            content.sound = .default
            
            // 3) Schedule for Sunday 9 AM, repeating weekly
            var comps = DateComponents()
            comps.weekday = 1    // Sunday == 1 in Calendar
            comps.hour    = 9
            comps.minute  = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
    
            let req = UNNotificationRequest(
                identifier: "weeklyPhotoDumpReminder",
                content: content,
                trigger: trigger
            )
            center.add(req)
            }
        }
        }

        // Handle foreground notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let id = response.notification.request.identifier
        if id == "weeklyPhotoDumpReminder" || id == "testDumpReminder" {
            NotificationCenter.default.post(
                name: .didTapDumpNotification,
                object: nil
            )
        }
        completionHandler()
    }
}
        
extension Notification.Name {
    static let didTapDumpNotification = Notification.Name("didTapDumpNotification")
}


@main
struct CliqueApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userViewModel = UserViewModel()
    
   // @available(iOS 17.0, *)
    var body: some Scene {
        WindowGroup {
            if userViewModel.currentUser == nil {
                // No Firebase user → show Login (email or Google)
               LoginView(userViewModel: userViewModel)
                } else if userViewModel.user == nil {
                // We have a Firebase user but no Firestore profile yet → setup screen
                ProfileSetupView(userViewModel: userViewModel)
            } else {
                // User is logged in
                MainTabView(userViewModel: userViewModel)
            }
        }
        
    }
}
