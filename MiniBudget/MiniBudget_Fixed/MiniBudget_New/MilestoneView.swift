//
//  MilestoneView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI
import UIKit

struct MilestoneView: View {

    // Real data passed from RewardsView
    let badgeName       : String
    let badgeIcon       : String
    let badgeColor      : String
    let badgeDescription: String
    let totalSaved      : Double
    let totalBadges     : Int
    let earnedDate      : Date?

    // Defaults for preview 
    init(
        badgeName       : String = "First Save",
        badgeIcon       : String = "star.fill",
        badgeColor      : String = "#4CAF50",
        badgeDescription: String = "Made your very first saving.",
        totalSaved      : Double = 3000,
        totalBadges     : Int    = 3,
        earnedDate      : Date?  = nil
    ) {
        self.badgeName        = badgeName
        self.badgeIcon        = badgeIcon
        self.badgeColor       = badgeColor
        self.badgeDescription = badgeDescription
        self.totalSaved       = totalSaved
        self.totalBadges      = totalBadges
        self.earnedDate       = earnedDate
    }

    @Environment(\.dismiss) private var dismiss
    @State private var showClaimAlert = false
    @State private var showShareSheet = false

    // Earned date string
    private var earnedDateString: String {
        guard let date = earnedDate else { return "Recently" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#E8F5E9").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Back button row
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // Trophy icon
                    trophyIcon
                        .padding(.top, 16)

                    // Headlines
                    headlines
                        .padding(.top, 16)
                        .padding(.horizontal, 24)

                    // Total Saved card
                    totalSavedCard
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    // Stats row
                    statsRow
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // Badge earned date row
                    earnedDateRow
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // Buttons
                    VStack(spacing: 12) {
                        claimBadgeButton
                        shareAchievementButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Badge Saved!", isPresented: $showClaimAlert) {
            Button("Awesome!", role: .cancel) {}
        } message: {
            Text("Your \"\(badgeName)\" badge is already in your Rewards collection.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "I just earned the \"\(badgeName)\" badge on Mini Budget! 💰🏆\nTotal saved: Rs. \(Int(totalSaved))"
            ])
        }
    }

    //  Trophy Icon 
    private var trophyIcon: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#FFF9C4").opacity(0.6))
                .frame(width: 110, height: 110)
            Circle()
                .fill(Color.white)
                .frame(width: 84, height: 84)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            Image(systemName: badgeIcon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(Color(hex: badgeColor))
            // Small green sparkle badge
            ZStack {
                Circle()
                    .fill(Color(hex: "#4CAF50"))
                    .frame(width: 24, height: 24)
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
            }
            .offset(x: 34, y: -34)
        }
    }

    //  Headlines 
    private var headlines: some View {
        VStack(spacing: 8) {
            Text("Milestone !!")
                .font(.system(size: 34, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))
            Text(badgeDescription)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#555555"))
                .multilineTextAlignment(.center)
        }
    }

    //  Total Saved Card 
    private var totalSavedCard: some View {
        VStack(spacing: 8) {
            Text("TOTAL SAVED")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "#9E9E9E"))
                .tracking(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Rs. \(Int(totalSaved))")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(Color(hex: "#1DB954"))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#1DB954"))
                Text("Keep saving to unlock more badges!")
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

    //  Stats Row 
    private var statsRow: some View {
        HStack(spacing: 12) {
            // Badge name card
            statCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BADGE")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.7)
                    HStack(spacing: 6) {
                        Image(systemName: badgeIcon)
                            .foregroundColor(Color(hex: badgeColor))
                            .font(.system(size: 14))
                        Text(badgeName)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // Total Badges card
            statCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL BADGES")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.7)
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color(hex: "#F5A623"))
                            .font(.system(size: 14))
                        Text("\(totalBadges)")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    Text("Top\nAchiever")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
            }
        }
    }

    private func statCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    //  Earned Date Row 
    private var earnedDateRow: some View {
        HStack {
            Image(systemName: "calendar.badge.checkmark")
                .foregroundColor(Color(hex: "#1DB954"))
                .font(.system(size: 16))
            Text("Earned on \(earnedDateString)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#555555"))
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    //  Claim Badge Button 
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

    //  Share Achievement Button 
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

//  Share Sheet 
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        MilestoneView(
            badgeName       : "First Save",
            badgeIcon       : "star.fill",
            badgeColor      : "#4CAF50",
            badgeDescription: "Made your very first saving.",
            totalSaved      : 3000,
            totalBadges     : 3,
            earnedDate      : Date()
        )
    }
}
