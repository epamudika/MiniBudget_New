//
//  RewardsView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI
import CoreData

struct RewardsView: View {

    @Binding var selectedTab: MBTab
    @Environment(\.managedObjectContext) private var viewContext

    //  Real badges from CoreData
    @FetchRequest(
        entity: BadgeEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BadgeEntity.badgeType, ascending: true)]
    ) private var badgeEntities: FetchedResults<BadgeEntity>

    //  Savings for totalSaved
    @FetchRequest(
        entity: SavingEntryEntity.entity(),
        sortDescriptors: []
    ) private var savings: FetchedResults<SavingEntryEntity>

    //  Navigation state
    @State private var selectedBadge: BadgeEntity? = nil
    @State private var navigateToMilestone: Bool   = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    //  Total saved from CoreData
    private var totalSaved: Double {
        savings.reduce(0) { $0 + $1.amount }
    }

    private var earnedCount: Int { badgeEntities.filter { $0.isEarned }.count }
    private var totalCount: Int  { badgeEntities.count }

    //  Map CoreData badge type to display info
    private func badgeInfo(for type: String) -> (name: String, description: String, icon: String, color: String) {
        switch type {
        case "First Save":
            return ("First Save",    "Made your very first saving.",             "star.fill",           "#4CAF50")
        case "7-Day Streak":
            return ("7-Day Streak",  "Saved for 7 days in a row.",               "flame.fill",          "#FF9800")
        case "30-Day Streak":
            return ("Gold Badge",    "Maintained a 30-day savings streak.",       "trophy.fill",         "#F5A623")
        case "Rs.500 Milestone":
            return ("Rs. 500 Saver", "Saved a total of Rs. 500.",                 "checkmark.seal.fill", "#2196F3")
        case "Rs.5000 Goal":
            return ("Goal Crusher",  "Reached your Rs. 5000 goal!",              "flag.fill",           "#9C27B0")
        case "Impulse Master":
            return ("Impulse Master","Avoided 5 unplanned purchases.",            "bolt.fill",           "#4CAF50")
        case "Budget Hero":
            return ("Budget Hero",   "Completed all categories under limit.",     "shield.fill",         "#2196F3")
        default:
            return (type,            "Keep saving to unlock!",                    "lock.fill",           "#9E9E9E")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {

                    progressHeader

                    if badgeEntities.isEmpty {
                        Text("Complete your goal setup to unlock badges!")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textCaption)
                            .multilineTextAlignment(.center)
                            .padding(40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(badgeEntities, id: \.id) { badge in
                                let info = badgeInfo(for: badge.badgeType ?? "")

                                //  Earned badges → tappable → navigate to MilestoneView
                                //  Locked badges → not tappable
                                if badge.isEarned {
                                    Button(action: {
                                        selectedBadge = badge
                                        navigateToMilestone = true
                                    }) {
                                        BadgeCard(
                                            name       : info.name,
                                            description: info.description,
                                            icon       : info.icon,
                                            color      : info.color,
                                            isEarned   : true
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    BadgeCard(
                                        name       : info.name,
                                        description: info.description,
                                        icon       : info.icon,
                                        color      : info.color,
                                        isEarned   : false
                                    )
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(AppTheme.background.ignoresSafeArea())
            // Navigate to MilestoneView with real badge data
            .navigationDestination(isPresented: $navigateToMilestone) {
                if let badge = selectedBadge {
                    let info = badgeInfo(for: badge.badgeType ?? "")
                    MilestoneView(
                        badgeName       : info.name,
                        badgeIcon       : info.icon,
                        badgeColor      : info.color,
                        badgeDescription: info.description,
                        totalSaved      : totalSaved,
                        totalBadges     : earnedCount,
                        earnedDate      : badge.earnedDate
                    )
                }
            }
        }
    }

    //  Progress Header
    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("MONTHLY PROGRESS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textCaption)
                .tracking(0.8)

            HStack(alignment: .top) {
                Text("\(max(totalCount - earnedCount, 0)) Badges left to\nunlock this Month")
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
                    Capsule().fill(AppTheme.paleGreen).frame(height: 8)
                    Capsule()
                        .fill(AppTheme.primaryGreen)
                        .frame(
                            width: totalCount > 0
                                ? geo.size.width * CGFloat(earnedCount) / CGFloat(totalCount)
                                : 0,
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

// BadgeCard
struct BadgeCard: View {

    let name        : String
    let description : String
    let icon        : String
    let color       : String
    let isEarned    : Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color(hex: color) : AppTheme.lockedGrey)
                    .frame(width: 54, height: 54)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            // Small "tap" hint for earned badges
            if isEarned {
                ZStack {
                    Circle().fill(Color(hex: color).opacity(0.15)).frame(width: 60, height: 60)
                        .offset(y: -37)
                        .allowsHitTesting(false)
                }
                .frame(height: 0)
            }

            Text(name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isEarned ? AppTheme.textPrimary : AppTheme.textCaption)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textCaption)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            if !isEarned {
                Text("LOCKED")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(AppTheme.lockedGrey)
                    .cornerRadius(8)
            } else {
                // "View" hint label for earned badges
                Text("TAP TO VIEW")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color(hex: color))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color(hex: color).opacity(0.12))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(AppTheme.cardWhite)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        .opacity(isEarned ? 1.0 : 0.75)
        //Subtle scale effect on earned badges to signal tappability
        .scaleEffect(isEarned ? 1.0 : 1.0)
    }
}

#Preview {
    RewardsView(selectedTab: .constant(.rewards))
}
