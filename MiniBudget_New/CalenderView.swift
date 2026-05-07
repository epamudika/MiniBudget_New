//
//  CalenderView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.


import SwiftUI

struct CalendarView: View {

    // Binding to tab bar
    @Binding var selectedTab: MainTab

    // State
    //Month currently being displayed.
    @State private var displayedMonth = Date()  // Defaults to current month

    //Day number tapped by the user (nil if none selected).
    @State private var selectedDay: Int? = nil

    // Constants
    private let calendar    = Calendar.current
    private let dayHeaders  = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    private let columns     = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    // ata
    private let savedDays   = MockData.savedDaysInMonth  // Set<Int> of saved day numbers
    private let goal        = MockData.goal

    // Computed: today's day number (only relevant if showing current month)
    private var todayDayNumber: Int { calendar.component(.day, from: Date()) }

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {

                // 1. Month navigation header
                monthNavigationHeader

                // 2. Day-of-week column headers
                dayOfWeekHeaders

                // 3. Day number grid
                dayGrid

                // 4. Savings Performance dark card
                savingsPerformanceCard

                // 5. Bottom stats row
                bottomStatsRow

                // Bottom padding for tab bar
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // Month navigation header
    // "< March 2026  Spring Savings Phase  >"
    private var monthNavigationHeader: some View {
        HStack {
            // Previous month button
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(spacing: 2) {
                // Month + Year
                Text(monthYearString(for: displayedMonth))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                // Sub-label "Spring Savings Phase"
                Text("SPRING SAVINGS PHASE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.8)
            }

            Spacer()

            // Next month button
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    //  Day-of-week headers
    private var dayOfWeekHeaders: some View {
        HStack(spacing: 0) {
            ForEach(dayHeaders, id: \.self) { header in
                Text(header)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.3)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // Day grid
    // A 7-column grid. Empty leading cells fill the first week row
    // to align day 1 with the correct weekday column.
    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            // Leading empty cells (e.g. if March starts on Saturday = 6 empties)
            ForEach(0..<leadingEmptyCells(), id: \.self) { _ in
                Color.clear.frame(height: 36)
            }

            // Day cells
            ForEach(1...daysInDisplayedMonth(), id: \.self) { day in
                dayCell(day: day)
            }
        }
    }

    // One day cell in the grid.
    private func dayCell(day: Int) -> some View {
        let isSaved   = savedDays.contains(day)
        let isToday   = (day == todayDayNumber) && isCurrentMonth()
        let isSelected = selectedDay == day

        return Button(action: { selectedDay = (selectedDay == day ? nil : day) }) {
            ZStack {
                // Cell background
                RoundedRectangle(cornerRadius: 8)
                    .fill(cellBackground(isSaved: isSaved, isToday: isToday, isSelected: isSelected))
                    .frame(height: 36)

                // Green ring highlight for today
                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.primaryGreen, lineWidth: 2)
                        .frame(height: 36)
                }

                // Day number text
                Text("\(day)")
                    .font(.system(size: 13, weight: isSaved || isToday ? .bold : .regular))
                    .foregroundColor(cellTextColor(isSaved: isSaved, isToday: isToday))
            }
        }
    }

    // Background fill colour for a calendar cell
    private func cellBackground(isSaved: Bool, isToday: Bool, isSelected: Bool) -> Color {
        if isSelected { return AppTheme.primaryGreen.opacity(0.3) }
        if isSaved    { return AppTheme.midGreen }
        return Color.white.opacity(0.01)   // Nearly transparent so grid lines show
    }

    // Text colour for a calendar cell
    private func cellTextColor(isSaved: Bool, isToday: Bool) -> Color {
        if isSaved  { return .white }
        if isToday  { return AppTheme.primaryGreen }
        return AppTheme.textSecondary
    }

    // Savings Performance card
    // Dark green card with month name + "PRE STATUS" badge +
    // two stat boxes: Days Saved and Month Total
    private var savingsPerformanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header row
            HStack {
                Text("SAVINGS PERFORMANCE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(0.8)
                Spacer()
                // "PRE STATUS" badge pill
                Text("PRE STATUS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.primaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }

            // Month name large
            Text(monthYearString(for: displayedMonth))
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)

            // Two stat boxes side by side
            HStack(spacing: 12) {
                performanceStatBox(label: "DAYS SAVED", value: "21")
                performanceStatBox(label: "MONTH TOTAL", value: "Rs.\n2500")
            }
        }
        .padding(16)
        .background(AppTheme.darkGreen)
        .cornerRadius(16)
    }

    // One stat box inside the dark Savings Performance card
    private func performanceStatBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.6)

            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    // Bottom stats row
    // "Best Streak 12 Days" and "Match Online Top 5%"
    private var bottomStatsRow: some View {
        HStack(spacing: 12) {
            bottomStatCard(
                icon: "flame.fill",
                label: "BEST STREAK",
                value: "12 Days",
                iconColor: AppTheme.primaryGreen
            )
            bottomStatCard(
                icon: "trophy.fill",
                label: "MATCH ONLINE",
                value: "Top 5%",
                iconColor: AppTheme.gold
            )
        }
    }

    // One card in the bottom stats row
    private func bottomStatCard(icon: String, label: String, value: String, iconColor: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.6)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // Calendar helper methods

    // Returns the number of days in the displayed month.
    private func daysInDisplayedMonth() -> Int {
        calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
    }

    //Returns the number of empty leading cells (to align day 1 correctly).
    private func leadingEmptyCells() -> Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return 0 }
        // weekday: 1 = Sunday, 2 = Monday … 7 = Saturday
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return weekday - 1  // Sunday=0 empty cells, Monday=1, etc.
    }

    // Returns "March 2026" formatted string for the displayed month.
    private func monthYearString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    // True if the displayed month is the same month as today.
    private func isCurrentMonth() -> Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    // Moves displayedMonth forward or backward by the given number of months.
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(.easeInOut(duration: 0.25)) {
                displayedMonth = newDate
                selectedDay = nil   // Clear selection when changing month
            }
        }
    }
}

#Preview {
    CalendarView(selectedTab: .constant(.calendar))
}

