//
//  RewardsView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.
//
import SwiftUI

struct RewardsView: View {

    //Data
    private let badges      = MockData.badges
    private let totalBadges = 6
    private let earnedCount = MockData.badges.filter(\.isEarned).count

    //Grid columns (2 per row)
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    //Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                //Progress header
                progressHeader

                //Badge grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(badges) { badge in
                        BadgeCard(badge: badge)
                    }
                }

                //Bottom padding
                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    //Progress header
    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("MONTHLY PROGRESS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textCaption)
                .tracking(0.8)

            HStack(alignment: .top) {
                Text("\(totalBadges - earnedCount) Badges left to\nunlock this Month")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(2)

                Spacer()

                Image(systemName: "trophy.fill")
                    .foregroundColor(AppTheme.gold)
                    .font(.system(size: 24))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.paleGreen)
                        .frame(height: 8)

                    Capsule()
                        .fill(AppTheme.primaryGreen)
                        .frame(
                            width: geo.size.width * CGFloat(earnedCount) / CGFloat(totalBadges),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            HStack {
                Spacer()
                Text("Total Badges: \(earnedCount)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.primaryGreen)
            }
        }
        .padding(16)
        .background(AppTheme.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

//BadgeCard Component
struct BadgeCard: View {

    let badge: BadgeItem

    var body: some View {
        VStack(spacing: 10) {

            // Icon circle
            ZStack {
                Circle()
                    .fill(badge.isEarned ? Color(hex: badge.color) : AppTheme.lockedGrey)
                    .frame(width: 54, height: 54)

                Image(systemName: badge.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Badge name
            Text(badge.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(badge.isEarned ? AppTheme.textPrimary : AppTheme.textCaption)
                .multilineTextAlignment(.center)

            // Description
            Text(badge.description)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textCaption)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            if !badge.isEarned {
                Text("LOCKED")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(AppTheme.lockedGrey)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(AppTheme.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        .opacity(badge.isEarned ? 1.0 : 0.75)
    }
}

#Preview {
    RewardsView()
}
