//
//  MakeDecisionView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI
import CoreData
import UIKit
import FirebaseFirestore


struct MakeDecisionView: View {

    let itemName        : String
    let price           : Double
    let category        : String
    let goalFasterDays  : Int
    let goalName        : String
    let growthPotential : String

    // Binding to switch to Rewards tab
    @Binding var selectedTab: MBTab

    init(
        itemName        : String = "Snack Pack",
        price           : Double = 500,
        category        : String = "Instant Food",
        goalFasterDays  : Int    = 12,
        goalName        : String = "New Car",
        growthPotential : String = "+4.2%",
        selectedTab     : Binding<MBTab> = .constant(.decision)
    ) {
        self.itemName        = itemName
        self.price           = price
        self.category        = category
        self.goalFasterDays  = goalFasterDays
        self.goalName        = goalName
        self.growthPotential = growthPotential
        self._selectedTab    = selectedTab
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    // Navigate to GreatChoiceView
    @State private var goToGreatChoice : Bool = false
    @State private var goToBuyConfirm  : Bool = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    backNavRow
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 22)

                    headlineSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 22)

                    saveInsteadCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                    buyItemAnyway
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)

                    saveTheMoneyButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }

            //Navigate to GreatChoiceView
            .navigationDestination(isPresented: $goToGreatChoice) {
                GreatChoiceView(
                    savedAmount  : price,
                    badgeName    : "Impulse Master\nBadge",
                    selectedTab  : $selectedTab
                )
                .navigationBarHidden(true)
            }

            .navigationDestination(isPresented: $goToBuyConfirm) {
                BuyConfirmView(itemName: itemName, price: price)
                    .navigationBarHidden(true)
            }
        }
        .navigationBarHidden(true)
    }

    // Back nav
    private var backNavRow: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text("Decision Timer")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color(hex: "#1A1A1A"))
        }
    }

    //  Headline
    private var headlineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What Do You Want?")
                .font(.system(size: 26, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("Your cooling-off period has expired.\nHow should we proceed with this ")
                    .foregroundColor(Color(hex: "#9E9E9E"))
                Text("Rs. \(Int(price))")
                    .foregroundColor(Color(hex: "#1DB954"))
                    .fontWeight(.bold)
                Text("?")
                    .foregroundColor(Color(hex: "#9E9E9E"))
            }
            .font(.system(size: 14))
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // Save Instead Card
    private var saveInsteadCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Text("GOAL REACHED \(goalFasterDays) DAYS FASTER!")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white)
                    .tracking(0.6)
                    .padding(.vertical, 7)
                Spacer()
            }
            .background(Color(hex: "#1B5E20"))
            .cornerRadius(12, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#1DB954"))
                    }
                    Text("Save Instead")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }

                Text("Boost your '\(goalName)' goal by adding this amount to your vault.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Growth Potential: \(growthPotential)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1DB954"))
            }
            .padding(16)
            .background(Color(hex: "#E8F5E9"))
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#1DB954"), lineWidth: 1.5))
        .shadow(color: Color(hex: "#1DB954").opacity(0.1), radius: 8, x: 0, y: 2)
    }

    //  Buy Item Anyway
    private var buyItemAnyway: some View {
        Button(action: { goToBuyConfirm = true }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#F0F0F0"))
                        .frame(width: 42, height: 42)
                    Image(systemName: "bag.fill")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
                Text("Buy Item Anyway")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#BDBDBD"))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }

    // Save the Money button
    private var saveTheMoneyButton: some View {
        Button(action: saveAndNavigate) {
            Text("Save the Money")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#1DB954"))
                .cornerRadius(14)
        }
    }

    // Save to CoreData, unlock badges, then go to GreatChoiceView
    private func saveAndNavigate() {
        // 1. Save the saving entry
        SavingEntryEntity.create(
            amount   : price,
            note     : "Saved on \(itemName)",
            streakDay: 0,
            in       : viewContext
        )

        if unlockBadge(type: "First Save") {
            NotificationManager.shared.sendBadgeEarnedNotification(badgeName: "First Save")
        }

        if unlockBadge(type: "Impulse Master") {
            NotificationManager.shared.sendBadgeEarnedNotification(badgeName: "Impulse Master")
        }

        let req = NSFetchRequest<SavingEntryEntity>(entityName: "SavingEntryEntity")
        let all  = (try? viewContext.fetch(req)) ?? []
        let total = all.reduce(0) { $0 + $1.amount } + price
        if total >= 500  {
            if unlockBadge(type: "Rs.500 Milestone") {
                NotificationManager.shared.sendBadgeEarnedNotification(badgeName: "Rs.500 Saver")
            }
        }
        if total >= 5000 {
            if unlockBadge(type: "Rs.5000 Goal") {
                NotificationManager.shared.sendBadgeEarnedNotification(badgeName: "Goal Crusher")
                // Also send goal reached notification
                if let goal = try? viewContext.fetch(NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")).first {
                    NotificationManager.shared.sendGoalReachedNotification(targetAmount: Int(goal.targetAmount))
                }
            }
        }

        //  Save to Firebase Firestore (cloud backup)
        if let uid = FirebaseManager.shared.currentProfile?.uid {
            Firestore.firestore()
                .collection("users").document(uid)
                .collection("savings").addDocument(data: [
                    "itemName" : itemName,
                    "amount"   : price,
                    "category" : category,
                    "savedAt"  : FieldValue.serverTimestamp(),
                    "type"     : "impulse_avoided"
                ]) { err in
                    if let err = err { print("Firestore savings error: \(err)") }
                    else { print("✅ Saving recorded in Firestore") }
                }
        }

        let newStreak = UserGoalEntity.updateStreak(in: viewContext)
        if [7, 14, 30].contains(Int(newStreak)) {
            NotificationManager.shared.sendStreakMilestoneNotification(streak: Int(newStreak))
        }

        NotificationManager.shared.sendMoneySavedNotification(itemName: itemName, amount: price)

        // 8. Persist CoreData
        PersistenceController.shared.save()

        goToGreatChoice = true
    }

    // Unlock a single badge by type string — returns true if newly unlocked
    @discardableResult
    private func unlockBadge(type: String) -> Bool {
        let req = NSFetchRequest<BadgeEntity>(entityName: "BadgeEntity")
        req.predicate  = NSPredicate(format: "badgeType == %@", type)
        req.fetchLimit = 1
        if let badge = try? viewContext.fetch(req).first, !badge.isEarned {
            badge.isEarned   = true
            badge.earnedDate = Date()
            return true
        }
        return false
    }
}

// cornerRadius corners helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(SpecificCornersShape(radius: radius, corners: corners))
    }
}

private struct SpecificCornersShape: Shape {
    let radius  : CGFloat
    let corners : UIRectCorner
    func path(in rect: CGRect) -> Path {
        let bezier = UIBezierPath(
            roundedRect      : rect,
            byRoundingCorners: corners,
            cornerRadii      : CGSize(width: radius, height: radius)
        )
        return Path(bezier.cgPath)
    }
}

//  BuyConfirmView
struct BuyConfirmView: View {
    let itemName : String
    let price    : Double
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                ZStack {
                    Circle().fill(Color(hex: "#FFF8E1")).frame(width: 100, height: 100)
                    Image(systemName: "bag.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "#F5A623"))
                }
                Text("Purchase Logged")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Text("\(itemName) — Rs. \(Int(price)) has been recorded.\nTry saving next time! 💪")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(3)
                Spacer()
                Button(action: { dismiss() }) {
                    Text("Back to Home")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#F5A623"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview("Make Decision") {
    NavigationStack {
        MakeDecisionView(
            itemName       : "Snack Pack",
            price          : 500,
            category       : "Instant Food",
            goalFasterDays : 12,
            goalName       : "New Car",
            growthPotential: "+4.2%"
        )
    }
}
