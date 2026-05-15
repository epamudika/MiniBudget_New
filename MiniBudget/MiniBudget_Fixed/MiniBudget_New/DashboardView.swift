//
//  DashboardView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct DashboardView: View {

    @Binding var selectedTab: MBTab

    //Firebase profile
    @ObservedObject private var firebase = FirebaseManager.shared

    // CoreData
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: UserGoalEntity.entity(),
        sortDescriptors: []
    ) private var goals: FetchedResults<UserGoalEntity>

    @FetchRequest(
        entity: SavingEntryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SavingEntryEntity.date, ascending: false)]
    ) private var savings: FetchedResults<SavingEntryEntity>

    // Computed values from real data
    private var currentGoal: UserGoalEntity? { goals.first }

    private var dailyAmount: Double  { currentGoal?.dailyAmount  ?? 0 }
    private var targetAmount: Double { currentGoal?.targetAmount ?? 0 }
    private var currentStreak: Int   { Int(currentGoal?.currentStreak ?? 0) }

    private var totalSaved: Double {
        savings.reduce(0) { $0 + $1.amount }
    }

    private var remaining: Double {
        max(targetAmount - totalSaved, 0)
    }

    private var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(totalSaved / targetAmount, 1.0)
    }

    private var dailyProgress: Double {
        guard dailyAmount > 0 else { return 0 }
        return min(totalSaved / dailyAmount, 1.0)
    }

    @State private var dailyGoalNotificationSent: Bool = false

    private var displayName: String {
        firebase.currentProfile?.fullName.components(separatedBy: " ").first ?? "User"
    }

    private var avatarLetter: String {
        String(displayName.prefix(1)).uppercased()
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // Top greeting bar
                    NavigationLink(destination: ProfileView()) {
                        topBar
                    }
                    .buttonStyle(PlainButtonStyle())

                    //Daily streak banner
                    streakBanner

                    // Today's goal card
                    todaysGoalCard

                    // Stats row
                    statsRow

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .onAppear {
                //Fetch Firebase profile if not loaded
                if firebase.currentProfile == nil,
                   let user = Auth.auth().currentUser {
                    firebase.fetchProfile(uid: user.uid)
                }
                // Sync widget data
                WidgetDataManager.shared.saveData(
                    totalSaved   : totalSaved,
                    targetAmount : targetAmount
                )
                // Check daily goal completion on appear
                checkDailyGoalCompletion()
            }
            .onChange(of: totalSaved) { _ in
                // Re-check whenever savings update
                checkDailyGoalCompletion()
            }
        }
    }

    private func checkDailyGoalCompletion() {
        guard dailyProgress >= 1.0, !dailyGoalNotificationSent else { return }
        dailyGoalNotificationSent = true
        NotificationManager.shared.sendDailyGoalCompletedNotification(dailyAmount: Int(dailyAmount))
    }

    // Top Bar
    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("WELCOME BACK")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.textCaption)
                    .tracking(0.8)

                HStack(spacing: 6) {
                    // Avatar with real initial
                    ZStack {
                        Circle()
                            .fill(AppTheme.paleGreen)
                            .frame(width: 32, height: 32)
                        Text(avatarLetter)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryGreen)
                    }
                    // Real name from Firebase
                    Text("\(greeting), \(displayName)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.textPrimary)
                .padding(8)
                .background(AppTheme.cardWhite)
                .clipShape(Circle())
        }
    }

    // Streak Banner
    private var streakBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DAILY CONSISTENCY")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .tracking(0.8)

            // Real streak from CoreData
            Text("\(currentStreak) Days Streak!")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)

            // Real progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 8)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 8)

            HStack {
                // Real progress percentage
                Text("\(Int(progress * 100))% to Goal")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                //  Real remaining amount
                Text("Rs. \(Int(remaining)) to go")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [AppTheme.lightGreen, AppTheme.primaryGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        )
    }

    // Today's Goal Card
    private var todaysGoalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(AppTheme.primaryGreen)
                Text("Today's Goal")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            // Real daily amount from CoreData
            Text("Rs. \(Int(dailyAmount))")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(AppTheme.textPrimary)

            // Real daily progress
            ProgressView(value: dailyProgress)
                .tint(AppTheme.primaryGreen)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .animation(.easeInOut(duration: 0.6), value: dailyProgress)

            //  Real percentage text
            Text("\(Int(dailyProgress * 100))% Completed")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textCaption)
        }
        .padding(20)
        .background(AppTheme.cardWhite)
        .cornerRadius(20)
    }

    //Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            // Real total saved
            statCard(
                icon: "checkmark.circle.fill",
                label: "Total Saved",
                value: "Rs. \(Int(totalSaved))"
            )
            // Real remaining (target - saved, min 0)
            statCard(
                icon: "target",
                label: "Remaining",
                value: "Rs. \(Int(remaining))"
            )
        }
    }

    private func statCard(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primaryGreen)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textCaption)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.cardWhite)
        .cornerRadius(18)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(.home))
}
