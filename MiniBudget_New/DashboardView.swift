//
//  DashboardView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.


import SwiftUI

struct DashboardView: View {

    // Binding to tab bar (allows switching tabs from here)
    @Binding var selectedTab: MainTab

    // Sample data (replace with @FetchRequest in production)
    private let goal = MockData.goal

    // Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {

                // 1. Top greeting bar
                topBar

                // 2. Daily streak banner
                streakBanner

                // 3. Today's goal card
                todaysGoalCard

                // 4. Stats row: This Week + Remaining Balance
                statsRow

                // 5. Bottom padding so content clears the tab bar
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    //Top bar
    private var topBar: some View {
        HStack(alignment: .center) {

            VStack(alignment: .leading, spacing: 2) {
                // Small "WELCOME BACK" label above the name
                Text("WELCOME BACK")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.8)

                // Main greeting
                HStack(spacing: 6) {
                    // Avatar circle with initials
                    ZStack {
                        Circle()
                            .fill(AppTheme.paleGreen)
                            .frame(width: 32, height: 32)
                        Text("E")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryGreen)
                    }
                    Text("Good Morning, Erandi")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }

            Spacer()

            // Bell notification icon
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(8)
                    .background(AppTheme.cardWhite)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
    }

    // Streak banner
    // Green gradient card with "12 Days Streak!" in large bold text.
    private var streakBanner: some View {
        ZStack(alignment: .topLeading) {
            // Green gradient background
            LinearGradient(
                colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 8) {

                // "DAILY CONSISTENCY" label
                Text("DAILY CONSISTENCY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(0.8)

                // Streak count headline
                Text("12 Days Streak!")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 6)

                        // Filled progress (80%)
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * 0.80, height: 6)
                    }
                }
                .frame(height: 6)

                // Bottom row: badge label + days label
                HStack {
                    Text("80% to Gold Badge")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    Text("3 Days to next Badge ")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
        }
        .frame(height: 120)
    }

    //Today's goal card
    private var todaysGoalCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Goal icon + label
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(AppTheme.primaryGreen)
                    .font(.system(size: 14))
                Text("Today's Goal")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            // Amount
            Text("Rs. \(Int(goal.dailyAmount))")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(AppTheme.textPrimary)

            // Progress bar toward daily goal (75%)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.paleGreen)
                        .frame(height: 8)
                    Capsule()
                        .fill(AppTheme.primaryGreen)
                        .frame(width: geo.size.width * 0.75, height: 8)
                }
            }
            .frame(height: 8)

            // "75%" label under progress bar
            Text("75%")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textCaption)
        }
        .padding(16)
        .background(AppTheme.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // Stats row
    // Two cards side by side: "This Week" and "Remaining Balance"
    private var statsRow: some View {
        HStack(spacing: 12) {

            // This Week card
            statCard(
                icon:    "calendar.circle.fill",
                label:   "This Week",
                value:   "Rs. \(Int(goal.remainingBalance))",
                subtext: "Remaining Balance"
            )

            // Remaining Balance card
            statCard(
                icon:    "arrow.down.circle.fill",
                label:   "Remaining Balance",
                value:   "Rs. \(Int(goal.remainingBalance))",
                subtext: "Remaining Balance"
            )
        }
    }

    // Reusable stat card used in the stats row
    private func statCard(icon: String, label: String, value: String, subtext: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primaryGreen)
                    .font(.system(size: 13))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(subtext)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textCaption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardWhite)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(.home))
}
