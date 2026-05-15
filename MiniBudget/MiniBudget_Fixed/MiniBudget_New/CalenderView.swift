//
//  CalenderView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI
import CoreData

struct CalendarView: View {

    @Binding var selectedTab: MBTab

    //Real data from CoreData
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: UserGoalEntity.entity(),
        sortDescriptors: []
    ) private var goals: FetchedResults<UserGoalEntity>

    @FetchRequest(
        entity: SavingEntryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SavingEntryEntity.date, ascending: false)]
    ) private var savings: FetchedResults<SavingEntryEntity>

    @State private var displayedMonth = Date()
    @State private var selectedDay: Int? = nil

    private let calendar    = Calendar.current
    private let dayHeaders  = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    private let columns     = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    //Computed real saved days for the displayed month
    private var savedDaysInDisplayedMonth: Set<Int> {
        var days = Set<Int>()
        let year  = calendar.component(.year,  from: displayedMonth)
        let month = calendar.component(.month, from: displayedMonth)

        for entry in savings {
            guard let date = entry.date, entry.amount > 0 else { continue }
            let entryYear  = calendar.component(.year,  from: date)
            let entryMonth = calendar.component(.month, from: date)
            if entryYear == year && entryMonth == month {
                days.insert(calendar.component(.day, from: date))
            }
        }
        return days
    }

    //Real stats computed from CoreData
    private var currentGoal: UserGoalEntity? { goals.first }

    private var daysSavedThisMonth: Int {
        savedDaysInDisplayedMonth.count
    }

    private var monthTotal: Double {
        let year  = calendar.component(.year,  from: displayedMonth)
        let month = calendar.component(.month, from: displayedMonth)

        return savings.filter { entry in
            guard let date = entry.date else { return false }
            return calendar.component(.year,  from: date) == year &&
                   calendar.component(.month, from: date) == month
        }.reduce(0) { $0 + $1.amount }
    }

    private var longestStreak: Int {
        Int(currentGoal?.longestStreak ?? 0)
    }

    private var matchRank: String {
        let streak = Int(currentGoal?.currentStreak ?? 0)
        switch streak {
        case 30...: return "Top 1%"
        case 20...: return "Top 5%"
        case 10...: return "Top 20%"
        case 5...:  return "Top 50%"
        default:    return "—"
        }
    }

    private var todayDayNumber: Int { calendar.component(.day, from: Date()) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                monthNavigationHeader
                dayOfWeekHeaders
                dayGrid
                savingsPerformanceCard
                bottomStatsRow
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // Month Navigation Header
    private var monthNavigationHeader: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(monthYearString(for: displayedMonth))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("SPRING SAVINGS PHASE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.8)
            }

            Spacer()

            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    // Day of Week Headers
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

    // Day Grid
    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<leadingEmptyCells(), id: \.self) { _ in
                Color.clear.frame(height: 36)
            }
            //Uses real savedDaysInDisplayedMonth
            ForEach(1...daysInDisplayedMonth(), id: \.self) { day in
                dayCell(day: day)
            }
        }
    }

    private func dayCell(day: Int) -> some View {
        //Check real saved days
        let isSaved    = savedDaysInDisplayedMonth.contains(day)
        let isToday    = (day == todayDayNumber) && isCurrentMonth()
        let isSelected = selectedDay == day

        return Button(action: { selectedDay = (selectedDay == day ? nil : day) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(cellBackground(isSaved: isSaved, isToday: isToday, isSelected: isSelected))
                    .frame(height: 36)

                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.primaryGreen, lineWidth: 2)
                        .frame(height: 36)
                }

                Text("\(day)")
                    .font(.system(size: 13, weight: isSaved || isToday ? .bold : .regular))
                    .foregroundColor(cellTextColor(isSaved: isSaved, isToday: isToday))
            }
        }
    }

    private func cellBackground(isSaved: Bool, isToday: Bool, isSelected: Bool) -> Color {
        if isSelected { return AppTheme.primaryGreen.opacity(0.3) }
        if isSaved    { return AppTheme.midGreen }
        return Color.white.opacity(0.01)
    }

    private func cellTextColor(isSaved: Bool, isToday: Bool) -> Color {
        if isSaved  { return .white }
        if isToday  { return AppTheme.primaryGreen }
        return AppTheme.textSecondary
    }

    //Savings Performance Card
    private var savingsPerformanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SAVINGS PERFORMANCE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(0.8)
                Spacer()
                Text("PRE STATUS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.primaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }

            Text(monthYearString(for: displayedMonth))
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                //Real days saved count from CoreData
                performanceStatBox(label: "DAYS SAVED",  value: "\(daysSavedThisMonth)")
                //Real mont total from CoreData
                performanceStatBox(label: "MONTH TOTAL", value: "Rs.\n\(Int(monthTotal))")
            }
        }
        .padding(16)
        .background(AppTheme.darkGreen)
        .cornerRadius(16)
    }

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

    // Bottom Stats Row
    private var bottomStatsRow: some View {
        HStack(spacing: 12) {
            //Real longest streak from CoreData
            bottomStatCard(
                icon: "flame.fill",
                label: "BEST STREAK",
                value: "\(longestStreak) Days",
                iconColor: AppTheme.primaryGreen
            )
            //Computed rank from streak
            bottomStatCard(
                icon: "trophy.fill",
                label: "MATCH ONLINE",
                value: matchRank,
                iconColor: AppTheme.gold
            )
        }
    }

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

    //Calendar Helpers
    private func daysInDisplayedMonth() -> Int {
        calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
    }

    private func leadingEmptyCells() -> Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return weekday - 1
    }

    private func monthYearString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func isCurrentMonth() -> Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(.easeInOut(duration: 0.25)) {
                displayedMonth = newDate
                selectedDay = nil
            }
        }
    }
}

#Preview {
    CalendarView(selectedTab: .constant(.calendar))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
