//
//  MilestoneView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.


import SwiftUI

struct MilestoneView: View {

    // Data
    // In production these come from Core Data / Firebase.
    // Here they are constants matching the wireframe values.
    private let totalSaved      : Double = 3000
    private let growthPercent   : Int    = 12
    private let bestDayAmount   : Double = 500
    private let bestDayLabel    : String = "Last\nTuesday"
    private let totalBadges     : Int    = 3
    private let topAchieverLabel: String = "Top\nAchiever"
    private let daysLogged      : Int    = 27
    private let totalDays       : Int    = 30
    private let daysToBonus     : Int    = 3

    // State
    // Controls whether the "Badge Claimed!" confirmation alert shows.
    @State private var showClaimAlert     = false
    // Controls whether the share sheet (UIActivityViewController) shows.
    @State private var showShareSheet     = false

    // Computed
    //Progress fraction for the circular ring (0.0 → 1.0)
    private var daysProgress: Double {
        Double(daysLogged) / Double(totalDays)
    }

    // Body
    var body: some View {
        ZStack(alignment: .bottom) {

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Light mint background fills the top section
                    ZStack(alignment: .top) {
                        // Mint background block behind trophy + headlines
                        MintBackgroundBlock()

                        VStack(spacing: 16) {
                            Spacer().frame(height: 24)

                            // 1. Trophy icon
                            trophyIcon

                            // 2 & 3. Headlines
                            headlines

                            // 4. Total Saved card
                            totalSavedCard
                                .padding(.horizontal, 20)

                            // 5. Stats row
                            statsRow
                                .padding(.horizontal, 20)

                            // 6. Days logged row
                            daysLoggedRow
                                .padding(.horizontal, 20)

                            Spacer().frame(height: 16)
                        }
                    }

                    // 7 & 8. Buttons (on white background)
                    VStack(spacing: 12) {
                        claimBadgeButton
                        shareAchievementButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // clears custom tab bar
                    .background(Color(hex: "#E8F5E9"))
                }
            }
            .background(Color(hex: "#E8F5E9").ignoresSafeArea())

            // Tab bar overlay
            MilestoneTabBar()
        }
        .ignoresSafeArea(edges: .bottom)
        // Alert shown when user claims the badge
        .alert("Badge Claimed! 🎉", isPresented: $showClaimAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your Milestone badge has been added to your Rewards.")
        }
        // Share sheet
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "I just saved Rs.\(Int(totalSaved)) with Mini Budget! 🐷💰"
            ])
        }
    }

    // Trophy icon ─────────────────────────────────
    // Yellow glowing circle with a trophy SF Symbol inside.
    // The outer ring is a slightly larger circle at low opacity.
    private var trophyIcon: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(Color(hex: "#FFF9C4").opacity(0.6))
                .frame(width: 90, height: 90)

            // Inner yellow circle
            Circle()
                .fill(Color(hex: "#FFF176"))
                .frame(width: 70, height: 70)

            // Trophy icon
            Image(systemName: "trophy.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "#F59E0B"))

            // Small green "+" sparkle badge (top-right of circle)
            ZStack {
                Circle()
                    .fill(Color(hex: "#4CAF50"))
                    .frame(width: 22, height: 22)
                Text("+")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
            }
            .offset(x: 28, y: -28)
        }
    }

    //Headlines
    private var headlines: some View {
        VStack(spacing: 6) {
            // Large bold "Milestone !!"
            Text("Milestone !!")
                .font(.system(size: 34, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))

            // Subtitle
            Text("You've nurtured your savings expertly.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#555555"))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    // Total Saved card
    // White rounded card showing total saved + growth trend.
    private var totalSavedCard: some View {
        VStack(spacing: 8) {

            // "TOTAL SAVED" small uppercase label
            Text("TOTAL SAVED")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "#9E9E9E"))
                .tracking(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Amount — large green bold
            Text("Rs. \(Int(totalSaved))")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Color(hex: "#1DB954"))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Growth trend row
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#1DB954"))

                Text("\(growthPercent)% more than last month")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#1DB954"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // Stats row
    // Two cards side by side: Best Day and Total Badges.
    private var statsRow: some View {
        HStack(spacing: 12) {

            // Best Day card
            statCard {
                VStack(alignment: .leading, spacing: 4) {
                    SectionCaption(text: "BEST DAY")
                    HStack(spacing: 6) {
                        // Gold coin icon
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#F5A623"))
                            .font(.system(size: 10))
                        Text("Rs.\n\(Int(bestDayAmount))")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    Text(bestDayLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
            }

            // Total Badges card
            statCard {
                VStack(alignment: .leading, spacing: 4) {
                    SectionCaption(text: "TOTAL BADGES")
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color(hex: "#F5A623"))
                            .font(.system(size: 14))
                        Text("\(totalBadges)")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    Text(topAchieverLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
            }
        }
    }

    // Generic white rounded card container used in the stats row.
    private func statCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    //Days Logged row
    private var daysLoggedRow: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .center) {

                // Left side text
                VStack(alignment: .leading, spacing: 4) {
                    SectionCaption(text: "DAYS LOGGED")

                    Text("\(daysLogged)/\(totalDays)")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }

                Spacer()

                // Circular progress ring showing days progress
                CircularProgressRing(
                    progress: daysProgress,
                    size: 54,
                    lineWidth: 5,
                    trackColor: Color(hex: "#E8F5E9"),
                    progressColor: Color(hex: "#1DB954"),
                    label: "\(Int(daysProgress * 100))%"
                )
            }

            // Tip text at the bottom
            Text("🏅 \(daysToBonus) days left to streak bonus!")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#555555"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // Claim Badge button
    private var claimBadgeButton: some View {
        Button(action: { showClaimAlert = true }) {
            HStack(spacing: 8) {
                Image(systemName: "rosette")
                    .font(.system(size: 16, weight: .semibold))
                Text("Claim Badge")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: "#1DB954"))
            .cornerRadius(14)
        }
    }

    // Share Achievement button
    private var shareAchievementButton: some View {
        Button(action: { showShareSheet = true }) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                Text("Share Achievement")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Color(hex: "#1DB954"))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#1DB954"), lineWidth: 1.5)
            )
        }
    }
}

// Supporting Views used by MilestoneView

// Mint green background block that fills the top half of the screen.
private struct MintBackgroundBlock: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: "#E8F5E9"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//Small uppercase grey section label.
//Used above stats inside cards ("BEST DAY", "TOTAL BADGES", etc.)
private struct SectionCaption: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(Color(hex: "#9E9E9E"))
            .tracking(0.7)
    }
}


struct CircularProgressRing: View {
    let progress      : Double
    let size          : CGFloat
    let lineWidth     : CGFloat
    let trackColor    : Color
    let progressColor : Color
    let label         : String

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress arc — starts at the top (-.pi/2 offset)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round   // Rounded arc tip
                    )
                )
                .rotationEffect(.degrees(-90))  // Start from top
                .animation(.easeInOut(duration: 0.8), value: progress)

            // Centre label
            Text(label)
                .font(.system(size: size * 0.22, weight: .bold))
                .foregroundColor(progressColor)
        }
        .frame(width: size, height: size)
    }
}

//Tab bar for the Milestone screen (Rewards tab is active).
private struct MilestoneTabBar: View {

    // Tab item data: icon, label, active?
    private let tabs: [(icon: String, label: String, active: Bool)] = [
        ("house",           "Home",     false),
        ("chart.bar",       "History",  false),
        ("star.fill",       "Rewards",  true ),
        ("calendar",        "Calendar", false),
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

// Wraps UIActivityViewController to present the iOS share sheet.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    MilestoneView()
}
