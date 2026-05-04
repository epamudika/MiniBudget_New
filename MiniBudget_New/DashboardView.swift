//
//  DashboardView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.
//
import SwiftUI

struct DashboardView: View {

    // Sample data
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

                // Space at bottom
                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // 1. Top bar
    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("WELCOME BACK")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.8)

                HStack(spacing: 6) {
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
    private var streakBanner: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 8) {
                Text("DAILY CONSISTENCY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(0.8)

                Text("12 Days Streak!")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 6)
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * 0.80, height: 6)
                    }
                }
                .frame(height: 6)

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

    // Today's goal card
    private var todaysGoalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(AppTheme.primaryGreen)
                    .font(.system(size: 14))
                Text("Today's Goal")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text("Rs. \(Int(goal.dailyAmount))")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(AppTheme.textPrimary)

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
    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                icon:    "calendar.circle.fill",
                label:   "This Week",
                value:   "Rs. 2500",
                subtext: "Total Saved"
            )

            statCard(
                icon:    "arrow.down.circle.fill",
                label:   "Remaining",
                value:   "Rs. \(Int(goal.remainingBalance))",
                subtext: " Balance"
            )
        }
    }

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

//Supporting Theme & Data (Required to run)
struct AppTheme {
    static let background = Color(red: 0.98, green: 0.99, blue: 0.98)
    static let primaryGreen = Color(red: 0.13, green: 0.58, blue: 0.29)
    static let lightGreen = Color(red: 0.40, green: 0.80, blue: 0.50)
    static let paleGreen = Color(red: 0.90, green: 0.96, blue: 0.92)
    static let cardWhite = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    static let textCaption = Color.gray.opacity(0.8)
}

struct MockGoal {
    let dailyAmount: Double
    let remainingBalance: Double
}

struct MockData {
    static let goal = MockGoal(dailyAmount: 500, remainingBalance: 2500)
}

#Preview {
    DashboardView()
}
