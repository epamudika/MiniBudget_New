//
//  GreatChoiceView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.


import SwiftUI

// GreatChoiceView

struct GreatChoiceView: View {

    // Input parameters
    // Passed forward from MakeDecisionView when the user taps "Save the Money"

    // The amount the user decided to save instead of spending.
    let savedAmount : Double

    // The name of the milestone badge that was unlocked.
    // Use "\n" inside the string to break it across two lines.
    let badgeName   : String

    // Convenience init with wireframe defaults
    init(
        savedAmount : Double = 500,
        badgeName   : String = "Impulse Master\nBadge"
    ) {
        self.savedAmount = savedAmount
        self.badgeName   = badgeName
    }

    //Environment
    // Provided by NavigationStack — used by the back button.
    @Environment(\.dismiss) private var dismiss

    // Animation state
    // Controls the pulsing sparkle animation around the coin.
    @State private var sparkleOn : Bool = false

    // Controls the fade-in + scale entrance animation for content.
    @State private var appeared  : Bool = false

    // Body
    var body: some View {
        ZStack {

            // Solid white background
            Color.white.ignoresSafeArea()

            // Full page layout
            VStack(spacing: 0) {

                // Back arrow — top-left
                HStack {
                    backArrow
                    Spacer()
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)

                Spacer()

                //Central content block
                VStack(spacing: 0) {

                    // Coin + hand illustration with sparkles
                    illustration
                        .padding(.bottom, 30)

                    // "Great Choice!" headline
                    Text("Great Choice!")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .padding(.bottom, 6)

                    // "Rs. 500 Added to Savings" green label
                    Text("Rs. \(Int(savedAmount)) Added to Savings")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#1DB954"))
                        .padding(.bottom, 28)

                    //  Thin horizontal divider line
                    Rectangle()
                        .fill(Color(hex: "#E8E8E8"))
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 22)

                    //  "MILESTONE UNLOCKED!" grey label
                    Text("MILESTONE UNLOCKED!")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .tracking(1.5)       // Wide letter-spacing for uppercase
                        .padding(.bottom, 12)

                    //  Badge name — bold, two lines, centred
                    Text(badgeName)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                // Entrance animation: fades in + scales up from 0.88
                .opacity(appeared ? 1.0 : 0.0)
                .scaleEffect(appeared ? 1.0 : 0.88)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.72),
                    value: appeared
                )

                Spacer()

                //  "Go to Rewards" green pill button — bottom of screen
                goToRewardsButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 44)
            }
        }
        .navigationBarHidden(true)
        // Trigger animations when the view first appears
        .onAppear {
            // Content fades in immediately
            appeared = true

            // Sparkle starts pulsing after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(
                    .easeInOut(duration: 1.4)
                    .repeatForever(autoreverses: true)
                ) {
                    sparkleOn = true
                }
            }
        }
    }


    // Back arrow ──────────────────────────────────────
    
    private var backArrow: some View {
        Button(action: { dismiss() }) {
            ZStack {
                // Light grey circular background for the tap area
                Circle()
                    .fill(Color(hex: "#F5F5F5"))
                    .frame(width: 34, height: 34)

                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
            }
        }
    }


    //  Coin + hand illustration
    
    private var illustration: some View {
        ZStack {

            // Layer 1: Warm yellow soft glow
            
            RadialGradient(
                colors: [
                    Color(hex: "#FFFDE7").opacity(0.95),
                    Color(hex: "#FFFDE7").opacity(0.0)
                ],
                center     : .center,
                startRadius: 5,
                endRadius  : 75
            )
            .frame(width: 160, height: 160)
            .blur(radius: 12)

            // ── Layer 2a: Green star sparkle (top-left)
            
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#66BB6A"))   // Medium green
                .offset(x: -38, y: -50)
                // Pulses between 1.0× and 1.3× scale
                .scaleEffect(sparkleOn ? 1.3 : 0.8)
                .animation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: sparkleOn
                )

            //  Layer 2b: Yellow sparkle (top-right)
            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#FFD740"))   // Bright yellow
                .offset(x: 44, y: -46)
                .scaleEffect(sparkleOn ? 1.0 : 1.35)     // Opposite phase
                .animation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: sparkleOn
                )

            //  Layer 3: Coin + hand
            VStack(spacing: -4) {

                // Gold coin (top)
                
                ZStack {
                    // Outer gold circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FFD740"),  // Bright gold
                                    Color(hex: "#FFA000")   // Darker amber
                                ],
                                startPoint: .topLeading,
                                endPoint:   .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        // Warm shadow beneath the coin
                        .shadow(
                            color  : Color(hex: "#FFA000").opacity(0.35),
                            radius : 8,
                            x      : 0,
                            y      : 4
                        )

                    // Small inner ring detail (mimics coin edge)
                    Circle()
                        .stroke(Color(hex: "#FFB300").opacity(0.6), lineWidth: 2)
                        .frame(width: 46, height: 46)

                    // Dollar sign on the coin face
                    Image(systemName: "dollarsign")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white.opacity(0.90))
                }

                //  Teal hand below the coin
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 42))
                    .foregroundColor(Color(hex: "#26A69A"))   // Teal
                    .scaleEffect(x: -1, y: 1)               // Mirror horizontally
                    .offset(y: 6)
            }
        }
        .frame(width: 180, height: 150)  // Fixed container size
    }


    // "Go to Rewards" button ─────────────────────────
    
    private var goToRewardsButton: some View {
        Button(action: {
            // ── Production implementation ──────────────────────
            // Option 1: Use a shared tab selection state
            //   tabSelection = .rewards
            //
            // Option 2: Post a notification
            //   NotificationCenter.default.post(
            //       name: Notification.Name("switchToRewards"), object: nil
            //   )
            //
            // For now: dismiss back to the home screen
            dismiss()
        }) {
            Text("Go to Rewards")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)    // Full width
                .frame(height: 52)
                .background(Color(hex: "#1DB954"))
                .cornerRadius(26)              // Full pill = height / 2
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
