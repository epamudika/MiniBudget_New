//
//  MonthlyReportView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.

import SwiftUI
import UIKit

struct MonthlyReportView: View {

    // Data
    private let reportMonth     : String  = "March"
    private let reportYear      : String  = "2026"
    private let totalSavings    : Double  = 3000
    private let bestDayAmount   : Double  = 500
    private let bestDayLabel    : String  = "Last\nTuesday"
    private let totalBadges     : Int     = 3
    private let topAchieverLabel: String  = "Top\nAchiever"

    private let weeklyBars: [(label: String, amount: Double, height: CGFloat)] = [
        ("WEEK 1", 400, 0.50),
        ("WEEK 2", 600, 0.70),
        ("WEEK 3", 750, 0.85),
        ("TODAY",  900, 1.00),  
    ]

    // Body
    var body: some View {
        ZStack(alignment: .bottom) {

            // Scrollable page content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Mint tinted top section
                    VStack(spacing: 12) {
                        Spacer().frame(height: 20)

                        //  Page title
                        pageTitle

                        //  Subtitle
                        subtitle

                        //  Total Savings label + amount
                        totalSavingsSection

                        // Bar chart
                        weeklyBarChart
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    .background(Color(hex: "#E8F5E9"))

                    // White section for stats
                    VStack(spacing: 0) {
                        Spacer().frame(height: 16)

                        // Stats row
                        statsRow
                            .padding(.horizontal, 16)

                        Spacer().frame(height: 100) 
                    }
                    .background(Color.white)
                }
            }
            .background(Color.white.ignoresSafeArea())

            // Tab bar
            ReportTabBar()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // Page title
    private var pageTitle: some View {
        Text("\(reportMonth) Report")
            .font(.system(size: 22, weight: .black))
            .foregroundColor(Color(hex: "#1DB954"))
            .multilineTextAlignment(.center)
    }

    // Subtitle
    private var subtitle: some View {
        Text("Your financial greenhouse is thriving this\n\(reportMonth).")
            .font(.system(size: 13))
            .foregroundColor(Color(hex: "#555555"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }

    // Total Savings
    private var totalSavingsSection: some View {
        VStack(spacing: 6) {
            // "TOTAL SAVINGS" uppercase label
            Text("TOTAL SAVINGS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "#555555"))
                .tracking(1.2)

            // Amount
            Text("Rs.\(Int(totalSavings))")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Color(hex: "#1DB954"))
        }
    }

    // Bar chart
    
    private var weeklyBarChart: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(weeklyBars.indices, id: \.self) { i in
                let bar = weeklyBars[i]
                VStack(spacing: 6) {
                    // The bar rectangle
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColor(for: bar.height))
                        .frame(
                            height: bar.height * 120  // Max bar height = 120 pt
                        )

                    // Week label below the bar
                    Text(bar.label)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.3)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 150)    // Total chart area height
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private func barColor(for height: CGFloat) -> Color {
        switch height {
        case 0.9...:  return Color(hex: "#1B5E20")   
        case 0.7...:   return Color(hex: "#2E7D32")   
        case 0.5...:   return Color(hex: "#4CAF50")   
        default:      return Color(hex: "#A5D6A7")   
        }
    }

    // Stats row
    private var statsRow: some View {
        HStack(spacing: 12) {

            // Best Day card
            reportStatCard {
                VStack(alignment: .leading, spacing: 6) {
                    statCaption("BEST DAY")
                    HStack(spacing: 6) {
                        // Gold coin circle
                        Circle()
                            .fill(Color(hex: "#F5A623"))
                            .frame(width: 12, height: 12)
                        Text("Rs.\n\(Int(bestDayAmount))")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    Text(bestDayLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
            }

            // Total Badges card
            reportStatCard {
                VStack(alignment: .leading, spacing: 6) {
                    statCaption("TOTAL BADGE")
                    HStack(spacing: 6) {
                        // Trophy icon
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color(hex: "#F5A623"))
                            .font(.system(size: 14))
                        Text("\(totalBadges)")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    Text(topAchieverLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
            }
        }
    }

    // White card container for one stat in the stats row.
    private func reportStatCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(hex: "#F5F5F5"))
            .cornerRadius(14)
    }

    // Small uppercase grey caption for stat card labels.
    private func statCaption(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(Color(hex: "#9E9E9E"))
            .tracking(0.7)
    }
}

// ReportTabBar


private struct ReportTabBar: View {

    private let tabs: [(icon: String, label: String, active: Bool)] = [
        ("house",      "Home",     false),
        ("chart.bar",  "History",  true ),  
        ("calendar",   "Calendar", false),
        ("star",       "Rewards",  false),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                let tab = tabs[i]
                VStack(spacing: 4) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: tab.active ? .semibold : .regular))
                        .foregroundColor(tab.active ? Color(hex: "#1DB954") : Color(hex: "#9E9E9E"))

                    Text(tab.label)
                        .font(.system(size: 10, weight: tab.active ? .semibold : .regular))
                        .foregroundColor(tab.active ? Color(hex: "#1DB954") : Color(hex: "#9E9E9E"))

                    // Active indicator dot
                    Circle()
                        .fill(tab.active ? Color(hex: "#1DB954") : Color.clear)
                        .frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
        }
        .frame(height: 60)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
        )
        .padding(.bottom,
            (UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.bottom) ?? 0
        )
    }
}

#Preview {
    MonthlyReportView()
}
