//
//  CountDownView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//


import SwiftUI
import Combine      // For Timer.publish


// CountDownView
struct CountDownView: View {

    // Input from AddPurchaseView
    let itemName : String
    let price    : Double
    let category : String

    // Environment
    @Environment(\.dismiss) private var dismiss

    // Timer state
    //Total seconds remaining. Starts at 86400 (= 24 hours).
    @State private var secondsRemaining : Int = 86_400

    //The Combine publisher that fires every second.
    //Stored so we can cancel it when the view disappears.
    @State private var timerCancellable : AnyCancellable? = nil

    // Navigation / result state
    // True when user taps "Make decision" — mark as saved.
    @State private var decisionMade  : Bool = false
    // True when user taps "Cancel" — mark as cancelled.
    @State private var cancelled     : Bool = false
    // Show the cancel confirmation alert.
    @State private var showCancelAlert: Bool = false

    //Computed properties

    // Progress fraction from 1.0 (full ring) to 0.0 (empty ring).
    private var progress: Double {
        Double(secondsRemaining) / Double(86_400)
    }

    //Ring colour: green while time remains, red when expired.
    private var ringColor: Color {
        secondsRemaining > 0 ? Color(hex: "#1DB954") : Color(hex: "#E53935")
    }

    // Formatted "HH:MM:SS" string for the centre of the ring.
    private var timeString: String {
        let h = secondsRemaining / 3600
        let m = (secondsRemaining % 3600) / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    // Days the user would reach their goal faster if they save.
    // In production calculate from Core Data goal data.
    private let goalFasterDays: Int = 12

    // Body
    var body: some View {
        ZStack(alignment: .bottom) {

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 28)

                    // Headline
                    headline

                    Spacer().frame(height: 20)

                    // Item info card
                    itemInfoCard
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 28)

                    // Countdown ring
                    countdownRing

                    Spacer().frame(height: 24)

                    // Tip card
                    tipCard
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 24)

                    // Action buttons
                    actionButtons
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 100)  // Clear tab bar
                }
            }
            .background(Color.white.ignoresSafeArea())

            // Tab bar
            CountDownTabBar()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        // Start the countdown when the view appears
        .onAppear { startTimer() }
        // Stop the timer when the view disappears
        .onDisappear { timerCancellable?.cancel() }
        // Cancel confirmation alert
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


    // Headline section
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


    // Item info card
    // White card showing:
    //   Left:  cart icon + item name (bold) + category (grey small)
    //   Right: "Rs." + price in large bold green
    private var itemInfoCard: some View {
        HStack(alignment: .center, spacing: 12) {

            // Cart icon in a light green circle
            ZStack {
                Circle()
                    .fill(Color(hex: "#E8F5E9"))
                    .frame(width: 40, height: 40)
                Image(systemName: "cart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#1DB954"))
            }

            // Item name + category
            VStack(alignment: .leading, spacing: 3) {
                Text(itemName.isEmpty ? "Snack Pack" : itemName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))

                Text(category.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .tracking(0.5)
            }

            Spacer()

            // Price — right-aligned, two-line layout
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


    // Countdown ring
    
    private var countdownRing: some View {
        ZStack {

            //Track circle (full grey background ring)
            Circle()
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 10)
                .frame(width: 180, height: 180)

            //Progress arc (green, depletes over time)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round    // Rounded arc ends
                    )
                )
                .rotationEffect(.degrees(-90))   // Start from 12 o'clock
                .frame(width: 180, height: 180)
                // Animate the ring smoothly on each second tick
                .animation(.linear(duration: 1.0), value: progress)

            // Centre text
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


    // Tip card
    // Light green card with a checkmark icon on the left and
    // the motivational tip text on the right.
    private var tipCard: some View {
        HStack(alignment: .top, spacing: 12) {

            // Green checkmark circle
            ZStack {
                Circle()
                    .fill(Color(hex: "#1DB954"))
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
            }
            .padding(.top, 2)

            // Tip text — dynamic, uses the goalFasterDays value
            Text("Wait 24 hours before you buy. If you save instead, you'll reach your new goal \(goalFasterDays) days faster!")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#1A1A1A"))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color(hex: "#E8F5E9"))    // Pale green card
        .cornerRadius(12)
    }


    // Action buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {

            // Make decision button (green)
            Button(action: {
                timerCancellable?.cancel()
                decisionMade = true
                dismiss()
            }) {
                Text("Make decision")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#1DB954"))
                    .cornerRadius(14)
            }

            // Cancel button (red outline + light red bg)
            Button(action: { showCancelAlert = true }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#E53935"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#FFEBEE"))    // Very light red bg
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#E53935").opacity(0.4), lineWidth: 1)
                    )
            }
        }
    }


    //Timer logic

    //Starts the Combine timer that fires every 1 second.
    private func startTimer() {
        // Timer.publish fires every 1 second on the main run loop.
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    // Timer expired — stop it
                    timerCancellable?.cancel()
                }
            }
    }
}


// CountDownTabBar


private struct CountDownTabBar: View {
    private let tabs: [(icon: String, label: String, active: Bool)] = [
        ("house",      "Home",     false),
        ("chart.bar",  "History",  false),
        ("calendar",   "Calendar", false),
        ("star.fill",  "Rewards",  true ),
    ]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                let t = tabs[i]
                VStack(spacing: 3) {
                    Image(systemName: t.icon)
                        .font(.system(size: 20, weight: t.active ? .semibold : .regular))
                        .foregroundColor(t.active ? Color(hex: "#1DB954") : Color(hex: "#9E9E9E"))
                    Text(t.label)
                        .font(.system(size: 10, weight: t.active ? .semibold : .regular))
                        .foregroundColor(t.active ? Color(hex: "#1DB954") : Color(hex: "#9E9E9E"))
                    Circle()
                        .fill(t.active ? Color(hex: "#1DB954") : Color.clear)
                        .frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity).padding(.top, 10)
            }
        }
        .frame(height: 60)
        .background(Color.white.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -2))
        .padding(.bottom, (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom) ?? 0)
    }
}


#Preview("Count Down") {
    NavigationStack {
        CountDownView(
            itemName: "Snack Pack",
            price:    500,
            category: "Instant Food"
        )
    }
}
