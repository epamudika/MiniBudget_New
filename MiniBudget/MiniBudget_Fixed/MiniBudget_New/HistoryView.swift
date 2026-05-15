//
//  HistoryView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI
import CoreData

struct HistoryView: View {

    @Binding var selectedTab: MBTab
    @State private var selectedFilter: HistoryFilter = .weekly

    enum HistoryFilter: String, CaseIterable {
        case weekly  = "Weekly"
        case monthly = "Monthly"
        case allTime = "All Time"
    }

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: SavingEntryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SavingEntryEntity.date, ascending: false)]
    ) private var allSavings: FetchedResults<SavingEntryEntity>

    //Filter savings based on selected tab
    private var filteredSavings: [SavingEntryEntity] {
        let now = Date()
        let cal = Calendar.current
        switch selectedFilter {
        case .weekly:
            let weekAgo = cal.date(byAdding: .day, value: -7, to: now) ?? now
            return allSavings.filter { ($0.date ?? Date()) >= weekAgo }
        case .monthly:
            let monthAgo = cal.date(byAdding: .month, value: -1, to: now) ?? now
            return allSavings.filter { ($0.date ?? Date()) >= monthAgo }
        case .allTime:
            return Array(allSavings)
        }
    }

    private var totalSaved: Double {
        filteredSavings.reduce(0) { $0 + $1.amount }
    }

    private var bestDay: Double {
        filteredSavings.map { $0.amount }.max() ?? 0
    }

    // Real last 7 days bar chart data from CoreData
    private var last7DaysBars: [WeeklyBar] {
        let cal = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, etc.

        return (0..<7).reversed().map { offset -> WeeklyBar in
            let day = cal.date(byAdding: .day, value: -offset, to: now) ?? now
            let dayStart = cal.startOfDay(for: day)
            let dayEnd   = cal.date(byAdding: .day, value: 1, to: dayStart) ?? day

            let amount = allSavings
                .filter { entry in
                    guard let d = entry.date else { return false }
                    return d >= dayStart && d < dayEnd
                }
                .reduce(0) { $0 + $1.amount }

            return WeeklyBar(label: formatter.string(from: day), amount: amount)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                filterTabs
                totalSavedSection
                statsRow
                growthOverviewCard

                //Recent saves list
                if !filteredSavings.isEmpty {
                    recentSavesList
                }

                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // Filter Tabs
    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = filter }
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: selectedFilter == filter ? .semibold : .regular))
                        .foregroundColor(selectedFilter == filter ? AppTheme.primaryGreen : AppTheme.textCaption)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedFilter == filter ? AppTheme.paleGreen : Color.clear)
                        .cornerRadius(20)
                }
            }
        }
        .padding(4)
        .background(AppTheme.cardGrey)
        .cornerRadius(24)
    }

    //Total Saved
    private var totalSavedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total Saved")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textCaption)
            //Real total from filtered CoreData
            Text("Rs. \(Int(totalSaved))")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    // Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            // Real best day amount
            historyStatCard(label: "BEST DAY",  value: "Rs. \(Int(bestDay))")
            // Real count of saves
            historyStatCard(label: "SAVES",     value: "\(filteredSavings.count)")
        }
    }

    private func historyStatCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textCaption)
                .tracking(0.6)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardGrey)
        .cornerRadius(14)
    }

    // Growth Overview Card
    private var growthOverviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Growth Overview")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Last 7 days performance")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textCaption)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(AppTheme.primaryGreen)
                    .font(.system(size: 14, weight: .semibold))
            }

            // Real bar chart
            barChart
        }
        .padding(16)
        .background(AppTheme.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // Bar Chart (real last 7 days)
    private var barChart: some View {
        let bars = last7DaysBars
        let maxAmount = bars.map(\.amount).max() ?? 1

        return HStack(alignment: .bottom, spacing: 8) {
            ForEach(bars) { bar in
                VStack(spacing: 4) {
                    // Real height from actual savings
                    RoundedRectangle(cornerRadius: 6)
                        .fill(bar.amount == maxAmount && maxAmount > 0
                              ? AppTheme.primaryGreen
                              : AppTheme.paleGreen)
                        .frame(height: maxAmount > 0
                               ? CGFloat(bar.amount / maxAmount) * 100
                               : 4)
                    Text(bar.label)
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.textCaption)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
        .padding(.top, 4)
    }

    //  Recent Saves List
    private var recentSavesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Saves")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(filteredSavings.prefix(10), id: \.id) { entry in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.note ?? "Saved")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        if let date = entry.date {
                            Text(date, style: .date)
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textCaption)
                        }
                    }
                    Spacer()
                    Text("Rs. \(Int(entry.amount))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primaryGreen)
                }
                .padding(12)
                .background(AppTheme.cardWhite)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
            }
        }
    }
}

#Preview {
    HistoryView(selectedTab: .constant(.history))
}
