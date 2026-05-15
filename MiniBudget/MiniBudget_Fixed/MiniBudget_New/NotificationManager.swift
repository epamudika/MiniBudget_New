//
//  NotificationManager.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.


import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}


    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async { completion?(granted) }
        }
    }


    func sendBadgeEarnedNotification(badgeName: String) {
        let content         = UNMutableNotificationContent()
        content.title       = "🏆 Badge Unlocked!"
        content.body        = "You just earned the \"\(badgeName)\" badge. Keep it up!"
        content.sound       = .default
        content.categoryIdentifier = "BADGE_EARNED"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id      = "badge_\(badgeName.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("Badge notification error: \(err)") }
            else { print("✅ Badge notification sent: \(badgeName)") }
        }
    }


    func sendDailyGoalCompletedNotification(dailyAmount: Int) {
        let today  = Calendar.current.startOfDay(for: Date())
        let dayKey = "daily_goal_done_\(Int(today.timeIntervalSince1970))"

        UNUserNotificationCenter.current().getDeliveredNotifications { delivered in
            let alreadyFired = delivered.contains { $0.request.identifier == dayKey }
            guard !alreadyFired else {
                print("⏭ Daily goal notification already sent today")
                return
            }

            let content   = UNMutableNotificationContent()
            content.title = "🎯 Daily Goal Smashed!"
            content.body  = "Amazing! You've saved Rs. \(dailyAmount) today. You're on track to reach your goal faster!"
            content.sound = .default
            content.categoryIdentifier = "DAILY_GOAL"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: dayKey,
                content   : content,
                trigger   : trigger
            )
            UNUserNotificationCenter.current().add(request) { err in
                if let err = err { print("Daily goal notification error: \(err)") }
                else { print("✅ Daily goal completed notification sent") }
            }
        }
    }


    func sendMoneySavedNotification(itemName: String, amount: Double) {
        let content   = UNMutableNotificationContent()
        content.title = "💚 Great Choice!"
        content.body  = "You resisted \"\(itemName)\" and saved Rs. \(Int(amount))! That money is now building your goal. 🚀"
        content.sound = .default
        content.categoryIdentifier = "MONEY_SAVED"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id      = "money_saved_\(itemName.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("Money saved notification error: \(err)") }
            else { print("✅ Money saved notification sent: Rs. \(Int(amount)) from \(itemName)") }
        }
    }


    func scheduleDailyReminder(at time: Date, dailyAmount: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily_reminder"]
        )

        let content         = UNMutableNotificationContent()
        content.title       = "💰 Daily Saving Reminder"
        content.body        = "Don't forget to save Rs. \(dailyAmount) today — your goal is waiting!"
        content.sound       = .default

        let cal        = Calendar.current
        var components = cal.dateComponents([.hour, .minute], from: time)
        components.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content   : content,
            trigger   : trigger
        )
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("Daily reminder error: \(err)") }
            else { print("✅ Daily reminder scheduled at \(components.hour ?? 0):\(components.minute ?? 0)") }
        }
    }


    func sendStreakMilestoneNotification(streak: Int) {
        guard [7, 14, 30].contains(streak) else { return }

        let content   = UNMutableNotificationContent()
        content.title = "🔥 \(streak)-Day Streak!"
        content.body  = "Amazing! You've saved for \(streak) days in a row. You're on fire!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_\(streak)",
            content   : content,
            trigger   : trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }


    func sendGoalReachedNotification(targetAmount: Int) {
        let content   = UNMutableNotificationContent()
        content.title = "🎉 Goal Reached!"
        content.body  = "You've saved Rs. \(targetAmount)! Time to set a new goal and keep going."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "goal_reached_\(targetAmount)",
            content   : content,
            trigger   : trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }


    func scheduleDecisionTimerExpired(itemName: String, price: Double, afterSeconds: TimeInterval = 86400) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["decision_\(itemName)"]
        )

        let content   = UNMutableNotificationContent()
        content.title = "⏰ Decision Time!"
        content.body  = "Your 24-hour cooling off for \"\(itemName)\" (Rs. \(Int(price))) has ended. Save or buy?"
        content.sound = .default
        content.categoryIdentifier = "DECISION_TIMER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: afterSeconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "decision_\(itemName)",
            content   : content,
            trigger   : trigger
        )
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("Decision timer error: \(err)") }
        }
    }


    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
