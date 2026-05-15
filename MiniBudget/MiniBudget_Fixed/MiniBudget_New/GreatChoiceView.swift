//
//  GreatChoiceView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI

struct GreatChoiceView: View {

    let savedAmount : Double
    let badgeName   : String

    // Binding to switch to Rewards tab
    @Binding var selectedTab: MBTab

    init(
        savedAmount : Double = 500,
        badgeName   : String = "Impulse Master\nBadge",
        selectedTab : Binding<MBTab> = .constant(.rewards)
    ) {
        self.savedAmount  = savedAmount
        self.badgeName    = badgeName
        self._selectedTab = selectedTab
    }

    @Environment(\.dismiss) private var dismiss
    @State private var sparkleOn : Bool = false
    @State private var appeared  : Bool = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                // Back arrow
                HStack {
                    backArrow
                    Spacer()
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)

                Spacer()

                // Central content
                VStack(spacing: 0) {

                    illustration
                        .padding(.bottom, 30)

                    Text("Great Choice!")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .padding(.bottom, 6)

                    Text("Rs. \(Int(savedAmount)) Added to Savings")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#1DB954"))
                        .padding(.bottom, 28)

                    Rectangle()
                        .fill(Color(hex: "#E8E8E8"))
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 22)

                    Text("MILESTONE UNLOCKED!")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(1.5)
                        .padding(.bottom, 12)

                    Text(badgeName)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .opacity(appeared ? 1.0 : 0.0)
                .scaleEffect(appeared ? 1.0 : 0.88)
                .animation(.spring(response: 0.55, dampingFraction: 0.72), value: appeared)

                Spacer()

                //  Go to Rewards button
                goToRewardsButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 44)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    sparkleOn = true
                }
            }
        }
    }

    // Back Arrow
    private var backArrow: some View {
        Button(action: { dismiss() }) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#F5F5F5"))
                    .frame(width: 34, height: 34)
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
            }
        }
    }

    // Illustration
    private var illustration: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: "#FFFDE7").opacity(0.95), Color(hex: "#FFFDE7").opacity(0.0)],
                center: .center, startRadius: 5, endRadius: 75
            )
            .frame(width: 160, height: 160)
            .blur(radius: 12)

            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#66BB6A"))
                .offset(x: -38, y: -50)
                .scaleEffect(sparkleOn ? 1.3 : 0.8)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: sparkleOn)

            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#FFD740"))
                .offset(x: 44, y: -46)
                .scaleEffect(sparkleOn ? 1.0 : 1.35)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: sparkleOn)

            VStack(spacing: -4) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#FFD740"), Color(hex: "#FFA000")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 56, height: 56)
                        .shadow(color: Color(hex: "#FFA000").opacity(0.35), radius: 8, x: 0, y: 4)
                    Circle()
                        .stroke(Color(hex: "#FFB300").opacity(0.6), lineWidth: 2)
                        .frame(width: 46, height: 46)
                    Image(systemName: "dollarsign")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white.opacity(0.90))
                }
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 42))
                    .foregroundColor(Color(hex: "#26A69A"))
                    .scaleEffect(x: -1, y: 1)
                    .offset(y: 6)
            }
        }
        .frame(width: 180, height: 150)
    }

    private var goToRewardsButton: some View {
        Button(action: {
            // Switch to Rewards tab — this pops back to MainTabView automatically
            selectedTab = .rewards
        }) {
            Text("Go to Rewards")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(hex: "#1DB954"))
                .cornerRadius(26)
        }
    }
}

#Preview("Great Choice") {
    NavigationStack {
        GreatChoiceView(
            savedAmount : 500,
            badgeName   : "Impulse Master\nBadge"
        )
    }
}
