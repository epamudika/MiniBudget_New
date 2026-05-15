//
//  PushNotification.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.

import SwiftUI
import UserNotifications   


// Data Model

struct NotificationItem: Identifiable {
    let id          = UUID()
    let icon        : String    // SF Symbol name
    let iconBG      : String    // Hex colour for the icon circle background
    let iconColor   : String    // Hex colour for the icon itself
    let title       : String    // Bold notification title
    let body        : String    // Grey notification body text
    let timeLabel   : String    // "1 hr ago", "3 hrs ago", "Yesterday"
    let isAlert     : Bool      // True = red left-border accent (Smart Decision)
}


// NotificationsView

struct PushNotificationView: View {

    //State

    // Whether Calendar Sync is switched on.
    @State private var calendarSyncEnabled : Bool = true

    // Controls whether the "Clear All" confirmation alert shows.
    @State private var showClearAlert      : Bool = false

    // The list of recent notification items.
    @State private var notifications: [NotificationItem] = [

        NotificationItem(
            icon:       "leaf.fill",
            iconBG:     "#E8F5E9",
            iconColor:  "#1DB954",
            title:      "Daily Reminder",
            body:       "It's time to water your financial seeds! Review your daily spending targets now.",
            timeLabel:  "1 hr ago",
            isAlert:    false
        ),

        NotificationItem(
            icon:       "leaf.circle.fill",   // Piggy-bank fallback
            iconBG:     "#E8F5E9",
            iconColor:  "#1DB954",
            title:      "Goal Reached!",
            body:       "Congrats! You've reached 80% of your \"Summer Trip\" savings goal. Keep growing!",
            timeLabel:  "3 hrs ago",
            isAlert:    false
        ),

        NotificationItem(
            icon:       "exclamationmark",
            iconBG:     "#FFEBEE",
            iconColor:  "#E53935",
            title:      "Smart Decision",
            body:       "You've decided if you get the headphones or save the money.",
            timeLabel:  "Yesterday",
            isAlert:    true    // Red left border accent
        ),
    ]

    // Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Logo row
                logoRow
                    .frame(maxWidth: .infinity)    // Centre horizontally
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                // Page headline
                pageHeadline
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // Calendar Sync toggle row
                calendarSyncRow
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                //Recent Activity section header
                recentActivityHeader
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // Notification list
                VStack(spacing: 10) {
                    ForEach(notifications) { item in
                        NotificationRow(item: item)
                    }
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 40)
            }
        }
        .background(Color(hex: "#F7F7F7").ignoresSafeArea())
        // "Clear All" confirmation alert
        .alert("Clear All Notifications?", isPresented: $showClearAlert) {
            Button("Clear All", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    notifications.removeAll()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all recent activity from Mini Budget.")
        }
    }


    // Logo row
    
    private var logoRow: some View {
        HStack(spacing: 8) {
            // Green piggy bank icon
           
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#1DB954"))

            Text("Mini Budget")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "#1DB954"))
        }
    }


    // Page headline
   
    private var pageHeadline: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Notifications")
                .font(.system(size: 26, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))

            Text("Manage your financial heartbeat.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
    }


    // Calendar Sync toggle row
    
    private var calendarSyncRow: some View {
        HStack(spacing: 14) {

            //Calendar icon in a red rounded square
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#FFEBEE"))   // Light red bg
                    .frame(width: 44, height: 44)

                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#E53935"))   // Red icon
            }

            //Text stack
            VStack(alignment: .leading, spacing: 3) {
                Text("Calendar Sync")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1A"))

                Text("Keep budget dates in check")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    // Allow text to wrap to two lines on smaller phones
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            //iOS-style Toggle
            Toggle("", isOn: $calendarSyncEnabled)
                .labelsHidden()
                .tint(Color(hex: "#1DB954"))
                // When toggled, request notification permission if turning ON
                .onChange(of: calendarSyncEnabled) { _, newValue in
                    if newValue { requestNotificationPermission() }
                }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }


    // Recent Activity header
    
    private var recentActivityHeader: some View {
        HStack {
            // Section label
            Text("RECENT ACTIVITY")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#9E9E9E"))
                .tracking(0.8)

            Spacer()

            // Clear All button
            Button(action: { showClearAlert = true }) {
                Text("Clear All")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1DB954"))
            }
        }
    }


    // Request notification permission

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    // If denied, revert the toggle
                    calendarSyncEnabled = false
                }
            }
        }
    }
}


//  NotificationRow


struct NotificationRow: View {

    let item: NotificationItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            //  Icon circle
            ZStack {
                Circle()
                    .fill(Color(hex: item.iconBG))
                    .frame(width: 40, height: 40)

                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: item.iconColor))
            }
            .padding(.top, 2)   // Align icon top with title text

            //  Text content
            VStack(alignment: .leading, spacing: 4) {

                // Title + time label row
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))

                    Spacer()

                    Text(item.timeLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#BDBDBD"))
                }

                // Body text — grey, wraps up to 3 lines
                Text(item.body)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#757575"))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            Group {
                if item.isAlert {
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "#E53935"))
                            .frame(width: 3)
                            .cornerRadius(2)
                        Spacer()
                    }
                }
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}


#Preview("Notifications Screen") {
    PushNotificationView()
}
