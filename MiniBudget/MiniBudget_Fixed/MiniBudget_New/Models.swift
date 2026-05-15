//
//  Models.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.

import Foundation

// Represents one saving event logged by the user.
struct SavingEntry: Identifiable {
    let id        = UUID()
    let date      : Date
    let amount    : Double    // Amount saved in rupees
    let note      : String?   // Optional note from the user
    let streakDay : Int       // Which day of the current streak this is
}

// The user's current savings goal (stored in Core Data in production).
struct UserGoal {
    var dailyAmount    : Double   // e.g. 500
    var targetAmount   : Double   // e.g. 5000
    var currentStreak  : Int      // e.g. 12
    var longestStreak  : Int
    var totalSaved     : Double   // Running total
    var daysLogged     : Int
    var bestDayAmount  : Double
    var monthRank      : String   // e.g. "Top 5%"
    var remainingBalance: Double

    // Progress from 0.0 to 1.0 toward the daily goal
    var dailyProgress: Double {
        min(totalSaved / targetAmount, 1.0)
    }
}

// One badge shown on the Rewards screen.
struct BadgeItem: Identifiable {
    let id          = UUID()
    let name        : String
    let description : String
    let icon        : String   // SF Symbol name
    let isEarned    : Bool
    let color       : String   // Hex colour for the icon background
}

// One bar entry for the History growth chart.
struct WeeklyBar: Identifiable {
    let id     = UUID()
    let label  : String   // e.g. "Mon", "Tue"
    let amount : Double
}

// Static sample data used in SwiftUI Previews and during development.
// Replace with real Core Data / Firebase fetches in production.
enum MockData {

    //  User goal (matches the wireframe numbers)
    static let goal = UserGoal(
        dailyAmount:      500,
        targetAmount:     5000,
        currentStreak:    12,
        longestStreak:    15,
        totalSaved:       3000,
        daysLogged:       27,
        bestDayAmount:    500,
        monthRank:        "Top 5%",
        remainingBalance: 2500
    )

    // Last 7 daily saving entries
    static let recentEntries: [SavingEntry] = {
        let cal = Calendar.current
        return (0..<7).map { offset in
            SavingEntry(
                date:      cal.date(byAdding: .day, value: -offset, to: Date()) ?? Date(),
                amount:    [500, 300, 500, 500, 0, 500, 200][offset],
                note:      nil,
                streakDay: 12 - offset
            )
        }
    }()

    //  Weekly bars for Growth Overview chart
    static let weeklyBars: [WeeklyBar] = [
        WeeklyBar(label: "Mon", amount: 300),
        WeeklyBar(label: "Tue", amount: 500),
        WeeklyBar(label: "Wed", amount: 200),
        WeeklyBar(label: "Thu", amount: 500),
        WeeklyBar(label: "Fri", amount: 400),
        WeeklyBar(label: "Sat", amount: 500),
        WeeklyBar(label: "Sun", amount: 350),
    ]

    // Badges
    static let badges: [BadgeItem] = [
        BadgeItem(name: "Impulse Master",   description: "Avoided 5 unplanned purchases this week.", icon: "bolt.fill",         isEarned: true,  color: "#4CAF50"),
        BadgeItem(name: "Gold Badge",       description: "Maintained a 30-day savings streak.",       icon: "trophy.fill",       isEarned: true,  color: "#F5A623"),
        BadgeItem(name: "Budget Hero",      description: "Completed all categories under limit.",      icon: "shield.fill",       isEarned: true,  color: "#2196F3"),
        BadgeItem(name: "Penny Pincher",    description: "Save Rs.100 in loose change.",               icon: "dollarsign.circle", isEarned: false, color: "#9E9E9E"),
        BadgeItem(name: "Investment Guru",  description: "Diversify your portfolio 5 times.",          icon: "chart.line.uptrend.xyaxis", isEarned: false, color: "#9E9E9E"),
        BadgeItem(name: "Early Bird",       description: "Pay all bills 3 days before due.",           icon: "alarm.fill",        isEarned: false, color: "#9E9E9E"),
    ]

    // Calendar saved days (day numbers in March that are saved)
    static let savedDaysInMonth: Set<Int> = [
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
        16,17,18,19,20,21,22,23,24,25,26,27
    ]
}
