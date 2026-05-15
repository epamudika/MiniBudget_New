//
//  ProfileView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct ProfileView: View {

    //  Real data from Firebase
    @ObservedObject private var firebase = FirebaseManager.shared

    //  Real data from CoreData
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: UserGoalEntity.entity(),
        sortDescriptors: []
    ) private var goals: FetchedResults<UserGoalEntity>

    @FetchRequest(
        entity: SavingEntryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SavingEntryEntity.date, ascending: false)]
    ) private var savings: FetchedResults<SavingEntryEntity>

    @FetchRequest(
        entity: BadgeEntity.entity(),
        sortDescriptors: []
    ) private var badges: FetchedResults<BadgeEntity>

    private var currentGoal: UserGoalEntity? { goals.first }

    private var totalSaved: Double {
        savings.reduce(0) { $0 + $1.amount }
    }

    private var currentStreak: Int {
        Int(currentGoal?.currentStreak ?? 0)
    }

    private var earnedBadgesCount: Int {
        badges.filter { $0.isEarned }.count
    }

    private var memberSinceText: String {
        let date = currentGoal?.startDate ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: date))"
    }

    private var userName: String {
        firebase.currentProfile?.fullName ?? "User"
    }

    private var bestDayOfWeek: String {
        let calendar = Calendar.current
        var dayTotals: [Int: Double] = [:]

        for entry in savings {
            guard let date = entry.date else { continue }
            let weekday = calendar.component(.weekday, from: date)
            dayTotals[weekday, default: 0] += entry.amount
        }

        guard let bestWeekday = dayTotals.max(by: { $0.value < $1.value })?.key else {
            return "—"
        }

        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return dayNames[max(0, min(bestWeekday - 1, 6))]
    }

    private var weeklyActivity: [(day: String, saved: Bool)] {
        let calendar = Calendar.current
        let dayLetters = ["S","M","T","W","T","F","S"]
        var result: [(day: String, saved: Bool)] = []

        for offset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            let dayLetter = dayLetters[weekday - 1]

            let hasSaving = savings.contains { entry in
                guard let entryDate = entry.date else { return false }
                return calendar.isDate(entryDate, inSameDayAs: date) && entry.amount > 0
            }
            result.append((day: dayLetter, saved: hasSaving))
        }
        return result
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)
                        avatarSection
                        totalSavingsSection
                        statsRow.padding(.horizontal, 20)
                        weeklyActivityCard.padding(.horizontal, 20)
                        Spacer().frame(height: 100)
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if firebase.currentProfile == nil,
               let user = Auth.auth().currentUser {
                firebase.fetchProfile(uid: user.uid)
            }
        }
    }

    //  Avatar Section
    private var avatarSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .stroke(Color(hex: "#1DB954").opacity(0.3), lineWidth: 2)
                    .frame(width: 84, height: 84)

                Circle()
                    .fill(Color(hex: "#E8F5E9"))
                    .frame(width: 78, height: 78)

                // Show initials from real Firebase name
                if !userName.isEmpty && userName != "User" {
                    Text(String(userName.prefix(1)).uppercased())
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color(hex: "#4CAF50"))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#4CAF50"))
                        .offset(y: 4)
                }

                ZStack {
                    Circle()
                        .fill(Color(hex: "#1DB954"))
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                }
                .offset(x: 2, y: 2)
            }
            .frame(width: 84, height: 84)

            //  Real name from Firebase
            Text(userName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1A"))

            //  Real member since from CoreData goal startDate
            Text(memberSinceText)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
    }

    //  Total Savings
    private var totalSavingsSection: some View {
        VStack(spacing: 6) {
            Text("TOTAL SAVINGS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "#9E9E9E"))
                .tracking(1.2)

            // Real total from CoreData savings entries
            Text("Rs.\(Int(totalSaved))")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(Color(hex: "#1DB954"))
        }
    }

    //Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            //  Best day computed from real savings data
            profileStatCard(bgColor: Color(hex: "#FFF8E1")) {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#F59E0B"))
                    Text("BEST DAY")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.7)
                    Text(bestDayOfWeek)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "#B45309"))
                }
            }

            //  Real badge count from CoreData
            profileStatCard(bgColor: Color(hex: "#FFF8E1")) {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#F59E0B"))
                    Text("BADGES")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(0.7)
                    Text("\(earnedBadgesCount) Collected")
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

    //  Weekly Activity Card
    private var weeklyActivityCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                Text("Weekly Activity")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Spacer()
                // ✅ Real streak count
                HStack(spacing: 4) {
                    Text("\(currentStreak)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#F59E0B"))
                    Text("STREAK")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "#1DB954"))
                        .tracking(0.5)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "#E8F5E9"))
                .cornerRadius(20)
            }

            //  Real weekly bar chart from CoreData
            let chartHeight: CGFloat = 80
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyActivity.indices, id: \.self) { i in
                    let item = weeklyActivity[i]
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(item.saved ? Color(hex: "#2E7D32") : Color(hex: "#C8E6C9"))
                            .frame(height: item.saved ? chartHeight : chartHeight * 0.20)
                        Text(item.day)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#9E9E9E"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: chartHeight + 20)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ProfileView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
