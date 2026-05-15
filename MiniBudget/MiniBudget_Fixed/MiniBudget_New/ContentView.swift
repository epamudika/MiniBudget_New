//
//  ContentView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.


import SwiftUI
import CoreData
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {

    @AppStorage("onboardingComplete")  private var onboardingComplete  = false
    @AppStorage("isLoggedInViaEmail")  private var isLoggedInViaEmail  = false

    @State private var isFaceIDPassed = false

    @ObservedObject private var firebase = FirebaseManager.shared
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        if onboardingComplete {
            if isLoggedInViaEmail || isFaceIDPassed {
                // Already authenticated — show main app
                MainTabView()
                    .onAppear { ensureGoalAndBadges() }
            } else {
                // Returning user — must pass Face ID first
                FaceIDView {
                    isFaceIDPassed = true
                }
            }
        } else {
            // First launch — onboarding flow
            NavigationStack {
                LoadingView()
            }
        }
    }

 
    private func ensureGoalAndBadges() {
        // Seed badges if missing
        BadgeEntity.seedAll(in: viewContext)
        PersistenceController.shared.save()

        // Check if we already have a goal in CoreData
        let req = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        req.fetchLimit = 1
        let count = (try? viewContext.count(for: req)) ?? 0
        guard count == 0 else { return }   // Goal already exists locally

        // No local goal — try fetch from Firestore
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { snap, _ in
            guard let data = snap?.data(),
                  let goalMap  = data["goal"] as? [String: Any],
                  let daily    = goalMap["dailyAmount"]  as? Double,
                  let target   = goalMap["targetAmount"] as? Double
            else { return }

            DispatchQueue.main.async {
                UserGoalEntity.createOrUpdate(
                    dailyAmount : daily,
                    targetAmount: target,
                    in          : viewContext
                )
                BadgeEntity.seedAll(in: viewContext)
                PersistenceController.shared.save()
            }
        }
    }
}

#Preview {
    ContentView()
}
