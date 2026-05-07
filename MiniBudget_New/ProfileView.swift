//
//  ProfileView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-05.
//

import SwiftUI


struct ProfileView: View {

    // In a real app these come from Core Data / Firebase.
    private let userName        : String  = "Erandi Pathirana"
    private let memberSince     : String  = "Member since March 2026"
    private let totalSavings    : Double  = 5000
    private let bestDay         : String  = "Tuesday"
    private let badgesCollected : Int     = 24
    private let streakCount     : Int     = 14

    // Weekly activity data — true = saved that day, false = no save.
    private let weeklyActivity: [(day: String, saved: Bool)] = [
        ("M", true),   // Monday    — saved
        ("T", false),  // Tuesday   — no save
        ("W", true),   // Wednesday — saved (tallest bar in wireframe)
        ("T", false),  // Thursday  — no save
        ("F", true),   // Friday    — saved
        ("S", false),  // Saturday  — no save
        ("S", false),  // Sunday    — no save
    ]

    var body: some View {
        ZStack(alignment: .bottom) {

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Top white area with all content
                    VStack(spacing: 20) {

                        Spacer().frame(height: 20)

                        // 1. Avatar + name + member since
                        avatarSection

                        // 2. Total Savings label + amount
                        totalSavingsSection

                        // 3. Best Day | Badges stats row
                        statsRow
                            .padding(.horizontal, 20)

                        // 4. Weekly Activity bar chart card
                        weeklyActivityCard
                            .padding(.horizontal, 20)

                        // Bottom padding so content clears the tab bar
                        Spacer().frame(height: 100)
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())

            ProfileTabBar()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    
    private var avatarSection: some View {
        VStack(spacing: 10) {

            // Avatar circle + badge
            ZStack(alignment: .bottomTrailing) {

                //Outer ring (thin green border)
                Circle()
                    .stroke(Color(hex: "#1DB954").opacity(0.3), lineWidth: 2)
                    .frame(width: 84, height: 84)

                // Avatar background circle
                Circle()
                    .fill(Color(hex: "#E8F5E9"))   // Light mint green background
                    .frame(width: 78, height: 78)

                // Person icon inside the circle
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#4CAF50"))
                    .offset(y: 4)    // Slight downward shift looks more natural

                // Positioned at the bottom-right of the avatar.
                ZStack {
                    Circle()
                        .fill(Color(hex: "#1DB954"))  // Solid green background
                        .frame(width: 22, height: 22)

                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                }
                // Push badge to the bottom-right corner of the avatar
                .offset(x: 2, y: 2)
            }
            .frame(width: 84, height: 84)

            // Name
            Text(userName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1A"))

            // Member since
            Text(memberSince)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
    }

 
    private var totalSavingsSection: some View {
        VStack(spacing: 6) {

            // Label
            Text("TOTAL SAVINGS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "#9E9E9E"))
                .tracking(1.2)   // Extra letter spacing for uppercase label

            // Amount
            Text("Rs.\(Int(totalSavings))")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(Color(hex: "#1DB954"))
        }
    }


    private var statsRow: some View {
        HStack(spacing: 12) {

            //  Best Day card
            profileStatCard(bgColor: Color(hex: "#FFF8E1")) {
                VStack(alignment: .leading, spacing: 6) {

                    // Sun icon
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#F59E0B"))

                    // Label
                    Text("BEST DAY")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.7)

                    // Value — amber/dark-yellow text
                    Text(bestDay)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "#B45309"))  // Dark amber
                }
            }

            // Badges card
            profileStatCard(bgColor: Color(hex: "#FFF8E1")) {
                VStack(alignment: .leading, spacing: 6) {

                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#F59E0B"))

                    // Label
                    Text("BADGES")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.7)

                    // Value — amber text
                    Text("\(badgesCollected) Collected")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "#B45309"))
                }
            }
        }
    }


    private func profileStatCard<Content: View>(
        bgColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(bgColor)
            .cornerRadius(16)
    }

 
    private var weeklyActivityCard: some View {
        VStack(spacing: 14) {

            // Card header
            HStack(alignment: .center) {

                // "Weekly Activity" title
                Text("Weekly Activity")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))

                Spacer()

                // "14 🔥 STREAK" green pill badge
                streakPill
            }

            //  Bar chart
            weeklyBarChart
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        // Card shadow
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

  
    private var streakPill: some View {
        HStack(spacing: 4) {
            Text("\(streakCount)")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))

            Image(systemName: "flame.fill")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#F59E0B"))   // Amber flame

            Text("STREAK")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "#1DB954"))   // Green text
                .tracking(0.5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(hex: "#E8F5E9"))   // Light mint pill background
        .cornerRadius(20)
    }

    // Weekly bar chart
 
    private var weeklyBarChart: some View {
        let chartHeight: CGFloat = 80    // Max bar height in points

        return HStack(alignment: .bottom, spacing: 8) {
            ForEach(weeklyActivity.indices, id: \.self) { i in
                let item = weeklyActivity[i]

                VStack(spacing: 4) {
                    // Bar rectangle
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            item.saved
                                ? Color(hex: "#2E7D32")   // Saved → dark green
                                : Color(hex: "#C8E6C9")   // Not saved → pale green
                        )
                        // Saved bars are tall; unsaved bars are short
                        .frame(height: item.saved ? chartHeight : chartHeight * 0.20)

                    // Day label below bar
                    Text(item.day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: chartHeight + 20)  // Extra 20pt for the day label row
        .animation(.easeInOut(duration: 0.5), value: weeklyActivity.map(\.saved))
    }
}


//ProfileTabBar


private struct ProfileTabBar: View {

    // Tab definitions — only Decision is active on the Profile screen.
    private let tabs: [(icon: String, label: String, active: Bool)] = [
        ("house",           "Home",     false),
        ("scale.3d",        "Decision", true ),   // ← Active
        ("calendar",        "Calendar", false),
        ("star",            "Rewards",  false),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                let tab = tabs[i]

                VStack(spacing: 3) {
                    // Icon
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: tab.active ? .semibold : .regular))
                        .foregroundColor(
                            tab.active
                                ? Color(hex: "#1DB954")
                                : Color(hex: "#9E9E9E")
                        )

                    // Label
                    Text(tab.label)
                        .font(.system(size: 10, weight: tab.active ? .semibold : .regular))
                        .foregroundColor(
                            tab.active
                                ? Color(hex: "#1DB954")
                                : Color(hex: "#9E9E9E")
                        )

                    // Active indicator dot — only shown on the active tab
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
        // Safe-area padding so the bar sits above the home indicator on iPhone
        .padding(.bottom,
            (UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.bottom) ?? 0
        )
    }
}



#Preview {
    ProfileView()
}
