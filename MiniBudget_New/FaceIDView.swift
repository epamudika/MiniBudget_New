//
//  FaceIDView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//


import SwiftUI
import LocalAuthentication   // Face ID


// Main View

struct FaceIDView: View {

    // Callback
    // Called by the parent (RootView) when auth succeeds so it
    // can switch to MainTabView.  Default is empty for previews.
    var onAuthenticated: () -> Void = {}

    // State
    @State private var isAuthenticating : Bool   = false  // Spinner on button
    @State private var errorMessage     : String = ""     // Shown on failure
    @State private var glowScale        : CGFloat = 1.0   // Drives glow pulse

    // Body
    var body: some View {
        ZStack {

            // Solid white background (full screen)
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // Logo
                logoRow
                    .padding(.bottom, 52)

                // Icon card with glow
                glowIconCard
                    .padding(.bottom, 36)

                // Headline
                Text("Face ID Required")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .padding(.bottom, 8)

                // Subtitle
                Text("Your Savings Data is Protected")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 28)

                // Unlock button ───────────────────
                unlockButton
                    .padding(.horizontal, 32)

                //  Error label (hidden when empty)
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 14)
                        .transition(.opacity.animation(.easeIn))
                }

                Spacer()

                // Home indicator spacer (bottom of screen)
                Spacer().frame(height: 20)
            }
        }
        // Auto-trigger Face ID as soon as the screen appears
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authenticate()
            }
        }
    }


    // Logo row ────────────────────────────
   
    private var logoRow: some View {
        HStack(spacing: 8) {

            // Piggy bank icon
            
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#1DB954"))

            // Brand name
            Text("Mini Budget")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#1DB954"))
        }
        // Pill-shaped white capsule with light shadow
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
    }


    
    private var glowIconCard: some View {
        ZStack {

            //  Pulsing green glow
           
            RadialGradient(
                colors: [
                    Color(hex: "#1DB954").opacity(0.28),
                    Color(hex: "#1DB954").opacity(0.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 90
            )
            .frame(width: 200, height: 200)
            .scaleEffect(glowScale)
            .blur(radius: 18)
            // Breathing animation: scale 1.0 → 1.15 → 1.0, forever
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    glowScale = 1.18
                }
            }

            // White card
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .frame(width: 118, height: 118)
                // Green-tinted shadow beneath the card
                .shadow(
                    color: Color(hex: "#1DB954").opacity(0.18),
                    radius: 20,
                    x: 0,
                    y: 6
                )

            // Corner bracket lines
           
            CornerBrackets(armLength: 14)
                .stroke(
                    Color(hex: "#1DB954").opacity(0.55),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 84, height: 84)

            // Face ID icon
            
            
            
            Image(systemName: "faceid")
                .font(.system(size: 46))
                .foregroundColor(Color(hex: "#1DB954"))

            // Sparkle star badge
            
            sparkleStarBadge
                .offset(x: 44, y: -44)
        }
    }

    // Small sparkle star badge used at the top-right of the card.
    private var sparkleStarBadge: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)

            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#1DB954"))
        }
    }


    // Unlock button
    //
    // Outlined pill button — white fill + green border + green text.
    // Shows a ProgressView spinner while authentication is running.
    // Disabled while isAuthenticating = true to prevent double-taps.
    private var unlockButton: some View {
        Button(action: authenticate) {
            ZStack {
                // Spinner shown while LAContext is evaluating
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: Color(hex: "#1DB954"))
                        )
                } else {
                    // Normal label text
                    Text("LOOK AT YOUR DEVICE TO UNLOCK")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#1DB954"))
                        .tracking(0.5)           // Letter spacing
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                // Green outline border
                Capsule()
                    .stroke(Color(hex: "#1DB954"), lineWidth: 1.5)
            )
        }
        .disabled(isAuthenticating)  // Prevent double-tap during auth
    }


    // Authentication

    
    // Step-by-step:
    //   1. Create a fresh LAContext for this evaluation attempt.
    //   2. Check canEvaluatePolicy — handles no enrolment, lockout, etc.
    //   3. If biometrics available → use .deviceOwnerAuthenticationWithBiometrics
    //   4. If not available → fall back to .deviceOwnerAuthentication
    //      which includes the passcode option.
    //   5. On success → call onAuthenticated() on the main thread.
    //   6. On failure → show the system error message to the user.
    private func authenticate() {
        // Reset state for a fresh attempt
        errorMessage     = ""
        isAuthenticating = true

        let context = LAContext()
        var policyError: NSError?

        // Can we use Face ID
        let hasBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &policyError
        )

        // Choose the policy based on what's available
        let policy: LAPolicy = hasBiometrics
            ? .deviceOwnerAuthenticationWithBiometrics  // Face ID / Touch ID
            : .deviceOwnerAuthentication                // Passcode fallback

        let reason = "Unlock Mini Budget to view your savings."

        context.evaluatePolicy(policy, localizedReason: reason) { success, evalError in

            // Always update UI on the main thread
            DispatchQueue.main.async {
                isAuthenticating = false

                if success {
                    // Auth passed → navigate to main app
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onAuthenticated()
                    }
                } else {
                    // Auth failed or cancelled → show why
                    // LAError codes: https://developer.apple.com/documentation/localauthentication/laerror
                    if let error = evalError as? LAError {
                        switch error.code {
                        case .userCancel:
                            // User tapped Cancel — silent, they can retry
                            errorMessage = ""
                        case .userFallback:
                            // User tapped "Enter Password" — re-trigger with passcode
                            authenticateWithPasscode()
                        case .biometryLockout:
                            errorMessage = "Face ID is locked. Please enter your passcode."
                            authenticateWithPasscode()
                        case .biometryNotEnrolled:
                            errorMessage = "Face ID not set up. Using passcode instead."
                            authenticateWithPasscode()
                        case .authenticationFailed:
                            errorMessage = "Face ID did not recognise you. Try again."
                        default:
                            errorMessage = error.localizedDescription
                        }
                    } else {
                        errorMessage = evalError?.localizedDescription ?? "Authentication failed."
                    }
                }
            }
        }
    }

    // Fallback: asks for device passcode when biometrics are
    // unavailable or locked out.
    private func authenticateWithPasscode() {
        isAuthenticating = true
        errorMessage     = ""

        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Enter your passcode to unlock Mini Budget."
        ) { success, error in
            DispatchQueue.main.async {
                isAuthenticating = false
                if success {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onAuthenticated()
                    }
                } else if let error = error as? LAError, error.code != .userCancel {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}


// CornerBrackets  (custom Shape)


struct CornerBrackets: Shape {

    /// Length of each arm of the L-shaped bracket in points.
    var armLength: CGFloat

    func path(in rect: CGRect) -> Path {
        var p    = Path()
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        let a    = armLength   // Shorthand

        //Top-left
        p.move(to:    CGPoint(x: minX, y: minY + a))  // Start: go down
        p.addLine(to: CGPoint(x: minX, y: minY))      // Corner: top-left
        p.addLine(to: CGPoint(x: minX + a, y: minY))  // Go right

        // ── Top-right  ¬ ──────────────────────────────────────
        p.move(to:    CGPoint(x: maxX - a, y: minY))  // Start: go left
        p.addLine(to: CGPoint(x: maxX, y: minY))      // Corner: top-right
        p.addLine(to: CGPoint(x: maxX, y: minY + a))  // Go down

        // ── Bottom-left  └ ────────────────────────────────────
        p.move(to:    CGPoint(x: minX, y: maxY - a))  // Start: go up
        p.addLine(to: CGPoint(x: minX, y: maxY))      // Corner: bottom-left
        p.addLine(to: CGPoint(x: minX + a, y: maxY))  // Go right

        // ── Bottom-right  ┘ ───────────────────────────────────
        p.move(to:    CGPoint(x: maxX - a, y: maxY))  // Start: go left
        p.addLine(to: CGPoint(x: maxX, y: maxY))      // Corner: bottom-right
        p.addLine(to: CGPoint(x: maxX, y: maxY - a))  // Go up

        return p
    }
}


// DELETE if already defined in your project




#Preview("Face ID Screen") {
    FaceIDView {
        print("✅ Authenticated — navigate to MainTabView")
    }
}
