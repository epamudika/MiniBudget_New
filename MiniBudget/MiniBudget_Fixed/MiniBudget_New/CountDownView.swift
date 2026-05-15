//
//  CountDownView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI
import UIKit
import Combine

struct CountDownView: View {

    // Input from AddPurchaseView
    let itemName : String
    let price    : Double
    let category : String

    @Binding var selectedTab: MBTab

    // Environment
    @Environment(\.dismiss) private var dismiss

    // Timer state
    @State private var secondsRemaining : Int = 86_400
    @State private var timerCancellable : AnyCancellable? = nil

    //Navigation to MakeDecisionView
    @State private var goToMakeDecision : Bool = false
    @State private var showCancelAlert  : Bool = false

    // Computed properties
    private var progress: Double {
        Double(secondsRemaining) / Double(86_400)
    }

    private var ringColor: Color {
        secondsRemaining > 0 ? Color(hex: "#1DB954") : Color(hex: "#E53935")
    }

    private var timeString: String {
        let h = secondsRemaining / 3600
        let m = (secondsRemaining % 3600) / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private let goalFasterDays: Int = 12

    var body: some View {
        ZStack(alignment: .bottom) {

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 28)
                    headline
                    Spacer().frame(height: 20)
                    itemInfoCard.padding(.horizontal, 24)
                    Spacer().frame(height: 28)
                    countdownRing
                    Spacer().frame(height: 24)
                    tipCard.padding(.horizontal, 24)
                    Spacer().frame(height: 24)
                    actionButtons.padding(.horizontal, 24)
                    Spacer().frame(height: 100)
                }
            }
            .background(Color.white.ignoresSafeArea())

            // Navigate to MakeDecisionView
            .navigationDestination(isPresented: $goToMakeDecision) {
                MakeDecisionView(
                    itemName       : itemName,
                    price          : price,
                    category       : category,
                    goalFasterDays : goalFasterDays,
                    goalName       : "My Goal",
                    growthPotential: "+4.2%",
                    selectedTab    : $selectedTab
                )
                .navigationBarHidden(true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear { startTimer() }
        .onDisappear { timerCancellable?.cancel() }
        .alert("Cancel this decision?", isPresented: $showCancelAlert) {
            Button("Yes, cancel", role: .destructive) {
                timerCancellable?.cancel()
                dismiss()
            }
            Button("No, keep waiting", role: .cancel) {}
        } message: {
            Text("The Rs.\(Int(price)) decision will be removed.")
        }
    }

    //Headline
    private var headline: some View {
        VStack(spacing: 6) {
            Text("Think Before Buy!")
                .font(.system(size: 26, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))
            Text("Cultivating mindful spending habits.")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
    }

    // Item Info Card
    private var itemInfoCard: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#E8F5E9"))
                    .frame(width: 40, height: 40)
                Image(systemName: "cart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#1DB954"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(itemName.isEmpty ? "Item" : itemName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Text(category.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .tracking(0.5)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("Rs.")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                Text("\(Int(price))")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(Color(hex: "#1A1A1A"))
            }
        }
        .padding(14)
        .background(Color(hex: "#F7F7F7"))
        .cornerRadius(14)
    }

    // Countdown Ring
    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 10)
                .frame(width: 180, height: 180)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 180, height: 180)
                .animation(.linear(duration: 1.0), value: progress)
            VStack(spacing: 4) {
                Text(timeString)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Text("HOURS REMAINING")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .tracking(0.5)
            }
        }
    }

    // Tip Card
    private var tipCard: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#1DB954"))
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
            }
            .padding(.top, 2)
            Text("Wait 24 hours before you buy. If you save instead, you'll reach your new goal \(goalFasterDays) days faster!")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#1A1A1A"))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color(hex: "#E8F5E9"))
        .cornerRadius(12)
    }

    //Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {

            //Make Decision → goes to MakeDecisionView
            Button(action: {
                timerCancellable?.cancel()
                goToMakeDecision = true
            }) {
                Text("Make decision")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#1DB954"))
                    .cornerRadius(14)
            }

            // Cancel button
            Button(action: { showCancelAlert = true }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#E53935"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#FFEBEE"))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#E53935").opacity(0.4), lineWidth: 1)
                    )
            }
        }
    }

    // Timer
    private func startTimer() {
        // Schedule a notification for when the 24-hr timer expires
        NotificationManager.shared.scheduleDecisionTimerExpired(
            itemName    : itemName,
            price       : price,
            afterSeconds: Double(secondsRemaining)
        )

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    timerCancellable?.cancel()
                }
            }
    }
}

#Preview("Count Down") {
    NavigationStack {
        CountDownView(
            itemName: "Snack Pack",
            price: 500,
            category: "Instant Food",
            selectedTab: .constant(.decision)
        )
    }
}
