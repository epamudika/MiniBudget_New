//
//  MiniBudget_NewApp.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI
import CoreData
import FirebaseCore
import UserNotifications

@main
struct MiniBudgetApp: App {

    // Core Data stack
    let persistence = PersistenceController.shared

    // App Delegate for notification delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Firebase init
    init() {
        FirebaseApp.configure()
    }

    //  Scene
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                     persistence.container.viewContext
                )
        }
    }
}



class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        NotificationManager.shared.requestPermission { granted in
            print(granted ? "Notification permission granted" : " Notification permission denied")
        }

        return true
    }
}


final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
