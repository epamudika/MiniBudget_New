//
//  EventKitCalenderView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//
import SwiftUI
import UIKit
import EventKit


// EventKitCalendarView

struct EventKitCalendarView: View {

    // Environment
    @Environment(\.dismiss) private var dismiss

    // State

    //Month displayed in the grid. Defaults to March 2026 to match
    @State private var displayedMonth: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 3; c.day = 1
        return Calendar.current.date(from: c) ?? Date()
    }()

    // Day numbers in the current month that have a saved entry.

    @State private var savedDays: Set<Int> = [
        1, 2, 4, 5, 8, 9, 12, 13, 14,
        16, 17, 18, 19, 20, 22, 23
    ]

    // Today's day number — used for the green ring highlight.
    @State private var todayDay: Int = 22

    // EventKit store for calendar permission + writing events.
    @State private var store         = EKEventStore()

    // Whether calendar access has been granted by the user.
    @State private var accessGranted = false

    // Alert controls for permission denial message.
    @State private var showPermAlert  = false
    @State private var permMessage    = ""

    // Layout constants
    private let dayHeaders = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    private let columns    = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    // Mock stats (replace with Core Data values in production)
    private let dailyAvg : Int = 119
    private let streak   : Int = 9

    // Body
    var body: some View {
        ZStack {
            // Light mint page background
            Color(hex: "#F2FFF5").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    navBar.padding(.horizontal, 16).padding(.top, 8)
                    headerSection.padding(.top, 10).padding(.bottom, 4)
                    calendarSyncRow.padding(.horizontal, 16).padding(.vertical, 14)
                    dayOfWeekRow.padding(.horizontal, 10)
                    dayGridSection.padding(.horizontal, 10).padding(.bottom, 16)
                    bottomStatsRow.padding(.horizontal, 16).padding(.bottom, 36)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { requestAccess() }
        .alert("Calendar Access Required", isPresented: $showPermAlert) {
            Button("Open Settings") { openSettings() }
            Button("Cancel", role: .cancel) {}
        } message: { Text(permMessage) }
    }


    // Nav bar
    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Home")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#1A1A1A"))
            }
            Spacer()
        }
    }


    // Header section
   
    private var headerSection: some View {
        VStack(spacing: 5) {
            // Logo
            HStack(spacing: 6) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#1DB954"))
                Text("Mini Budget")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#1DB954"))
            }
            // Month + year
            Text(monthYearString())
                .font(.system(size: 24, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))
            // Subtitle
            Text("Savings Performance")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
    }


    private var calendarSyncRow: some View {
        HStack(spacing: 14) {

            // Red calendar icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#FFEBEE"))
                    .frame(width: 44, height: 44)
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#E53935"))
            }

            // Text labels
            VStack(alignment: .leading, spacing: 3) {
                Text("Calendar Sync")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Text("Keep budget dates in check")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#9E9E9E"))
            }

            Spacer()

            Circle()
                .fill(accessGranted ? Color(hex: "#1DB954") : Color(hex: "#BDBDBD"))
                .frame(width: 10, height: 10)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }


    private var dayOfWeekRow: some View {
        HStack(spacing: 0) {
            ForEach(dayHeaders, id: \.self) { h in
                Text(h)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(hex: "#BDBDBD"))
                    .tracking(0.3)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }


    // Day grid
   
    private var dayGridSection: some View {
        LazyVGrid(columns: columns, spacing: 0) {

            // Leading empty cells align day 1 to the right column
            ForEach(0..<leadingEmpty(), id: \.self) { _ in
                Color.clear.frame(height: 46)
            }

            // Actual day cells
            ForEach(1...daysInMonth(), id: \.self) { day in
                CalendarDayCell(
                    day:      day,
                    isSaved:  savedDays.contains(day),
                    isToday:  day == todayDay,
                    isFuture: day > todayDay
                )
                .onTapGesture {
                    if savedDays.contains(day) { syncDay(day) }
                }
            }
        }
    }


    private var bottomStatsRow: some View {
        HStack(spacing: 12) {
            statsCard(
                icon: "arrow.up.right.circle.fill",
                iconColor: Color(hex: "#1DB954"),
                iconBG:    Color(hex: "#D4EDDA"),
                label: "DAILY AVG",
                value: "Rs. \(dailyAvg)"
            )
            statsCard(
                icon: "flame.circle.fill",
                iconColor: Color(hex: "#E53935"),
                iconBG:    Color(hex: "#FFD6D6"),
                label: "CURRENT STREAK",
                value: "\(streak) Days"
            )
        }
    }

    // One stats card used in the bottom row.
    private func statsCard(
        icon: String, iconColor: Color, iconBG: Color,
        label: String, value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle().fill(iconBG).frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(Color(hex: "#9E9E9E"))
                .tracking(0.5)
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(hex: "#E8F5E9"))
        .cornerRadius(16)
    }


    // EventKit logic

    
    private func requestAccess() {
        if #available(iOS 17.0, *) {
            // iOS 17+: requestWriteOnlyAccessToEvents is preferred —
            // it asks for less permission and users are more likely to grant it.
            store.requestWriteOnlyAccessToEvents { granted, _ in
                DispatchQueue.main.async { accessGranted = granted }
            }
        } else {
            store.requestAccess(to: .event) { granted, _ in
                DispatchQueue.main.async {
                    accessGranted = granted
                    if !granted {
                        permMessage   = "Allow calendar access in Settings to sync savings."
                        showPermAlert = true
                    }
                }
            }
        }
    }

   
    private func syncDay(_ day: Int) {
        guard accessGranted else { return }

        var c   = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        c.day   = day
        guard let date = Calendar.current.date(from: c) else { return }

        let start = Calendar.current.startOfDay(for: date)
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? date

        // Get (or create) the Mini Budget calendar
        let cal = minibudgetCalendar()

        // Check for existing event — avoid duplicates
        let pred     = store.predicateForEvents(withStart: start, end: end, calendars: [cal])
        let existing = store.events(matching: pred)
        guard existing.isEmpty else {
            print("EventKit: event already exists for day \(day)")
            return
        }

        // Create and save a new all-day event
        let ev       = EKEvent(eventStore: store)
        ev.title     = " Mini Budget saving logged"
        ev.isAllDay  = true
        ev.startDate = start
        ev.endDate   = start       
        ev.calendar  = cal
        ev.notes     = "Saving recorded via Mini Budget app."

        do {
            try store.save(ev, span: .thisEvent)
            print("EventKit: synced day \(day) to Apple Calendar")
        } catch {
            print("EventKit save error: \(error.localizedDescription)")
        }
    }

    private func minibudgetCalendar() -> EKCalendar {
        if let existing = store.calendars(for: .event)
            .first(where: { $0.title == "Mini Budget" }) {
            return existing
        }
        let cal   = EKCalendar(for: .event, eventStore: store)
        cal.title = "Mini Budget"
        cal.source = store.defaultCalendarForNewEvents?.source
            ?? store.sources.first { $0.sourceType == .local }
            ?? store.sources.first!
        cal.cgColor = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1).cgColor
        try? store.saveCalendar(cal, commit: true)
        return cal
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }


    //Calendar math helpers

    private func monthYearString() -> String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth)
    }

    // Number of days in the displayed month.
    private func daysInMonth() -> Int {
        Calendar.current.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
    }

    // Number of blank leading cells so day 1 starts on Sunday (0) or
    private func leadingEmpty() -> Int {
        var c = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        c.day = 1
        guard let first = Calendar.current.date(from: c) else { return 0 }
        return Calendar.current.component(.weekday, from: first) - 1
    }
}


//  CalendarDayCell


struct CalendarDayCell: View {

    let day      : Int
    let isSaved  : Bool
    let isToday  : Bool
    let isFuture : Bool

    // Colours
    private var numberColor: Color {
        if isFuture { return Color(hex: "#CCCCCC") }
        if isSaved || isToday { return Color(hex: "#1DB954") }
        return Color(hex: "#9E9E9E")
    }

    private var dotColor: Color {
        isSaved ? Color(hex: "#1DB954") : Color.clear
    }

    var body: some View {
        VStack(spacing: 2) {

            // Day number
            ZStack {
                if isToday {
                    Circle()
                        .stroke(Color(hex: "#1DB954"), lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                }
                Text("\(day)")
                    .font(.system(
                        size: 13,
                        weight: (isSaved || isToday) ? .bold : .regular
                    ))
                    .foregroundColor(numberColor)
            }
            .frame(width: 30, height: 30)

            Circle()
                .fill(dotColor)
                .frame(width: 4, height: 4)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
    }
}



#Preview("EventKit Calendar") {
    NavigationStack {
        EventKitCalendarView()
    }
}
