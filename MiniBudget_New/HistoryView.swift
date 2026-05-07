//
//  HistoryView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.
//


import SwiftUI

struct HistoryView: View {

    // Binding to tab bar
    @Binding var selectedTab: MainTab

    // State
    // Currently selected time filter.
    @State private var selectedFilter: HistoryFilter = .weekly

    // Filter options shown as pill chips at the top.
    enum HistoryFilter: String, CaseIterable {
        case weekly   = "Weekly"
        case monthly  = "Monthly"
        case allTime  = "All Time"
    }

    // MARK: - Data
    private let goal = MockData.goal
    private let bars = MockData.weeklyBars

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                // 1. Filter pill selector
                filterTabs

                // 2. Total saved headline
                totalSavedSection

                // 3. Best Day / Days Logged stats row
                statsRow

                // 4. Growth Overview chart card
                growthOverviewCard

                // Bottom padding for tab bar
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // Filter tabs
    // Three pill buttons. Selected = white bg inside green pill.
    // Unselected = transparent with grey text.
    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: selectedFilter == filter ? .semibold : .regular))
                        .foregroundColor(
                            selectedFilter == filter ? AppTheme.primaryGreen : AppTheme.textCaption
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            selectedFilter == filter
                                ? AppTheme.paleGreen
                                : Color.clear
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(4)
        .background(AppTheme.cardGrey)
        .cornerRadius(24)
    }

    // Total saved headline
    private var totalSavedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total Saved")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textCaption)

            Text("Rs. \(Int(goal.totalSaved))")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    // Stats row
    // Two cards: Best Day and Days Logged
    private var statsRow: some View {
        HStack(spacing: 12) {
            historyStatCard(
                label: "BEST DAY",
                value: "Rs. \(Int(goal.bestDayAmount))",
                valueColor: AppTheme.textPrimary
            )
            historyStatCard(
                label: "DAYS LOGGED",
                value: "\(goal.daysLogged)/30",
                valueColor: AppTheme.textPrimary
            )
        }
    }

    // One grey stat card used in the stats row
    private func historyStatCard(label: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textCaption)
                .tracking(0.6)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardGrey)
        .cornerRadius(14)
    }

    // Growth Overview card ────────────────────────
    // White card containing:
    //   • "Growth Overview" title + "Last 7 days performance" subtitle
    //   • Bar chart of the last 7 days
    private var growthOverviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Card header
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Growth Overview")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    // Trend up icon
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(AppTheme.primaryGreen)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text("Last 7 days performance")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textCaption)
            }

            // Bar chart
            barChart

        }
        .padding(16)
        .background(AppTheme.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // Bar chart
    // Pure SwiftUI — no Charts framework needed (iOS 15 compatible).
    // Each bar is a RoundedRectangle scaled to its value proportion.
    private var barChart: some View {
        let maxAmount = bars.map(\.amount).max() ?? 1

        return HStack(alignment: .bottom, spacing: 8) {
            ForEach(bars) { bar in
                VStack(spacing: 4) {
                    // The bar itself — height proportional to amount
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            // Tallest bar is darker green; others are lighter
                            bar.amount == maxAmount
                                ? AppTheme.primaryGreen
                                : AppTheme.paleGreen
                        )
                        .frame(
                            height: CGFloat(bar.amount / maxAmount) * 100
                        )

                    // Day label below the bar
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
}

#Preview {
    HistoryView(selectedTab: .constant(.history))
}
