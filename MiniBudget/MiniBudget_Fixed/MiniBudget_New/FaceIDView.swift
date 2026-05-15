//
//  FaceIDView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI
import LocalAuthentication

struct FaceIDView: View {

    var onAuthenticated: () -> Void = {}

    @State private var isAuthenticating : Bool    = false
    @State private var errorMessage     : String  = ""
    @State private var glowScale        : CGFloat = 1.0
    @State private var goToLogin        : Bool    = false

    @AppStorage("isLoggedInViaEmail") private var isLoggedInViaEmail = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {

                    Spacer()

                    logoRow
                        .padding(.bottom, 52)

                    glowIconCard
                        .padding(.bottom, 36)

                    Text("Face ID Required")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .padding(.bottom, 8)

                    Text("Your Savings Data is Protected")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 28)

                    // Face ID unlock button
                    unlockButton
                        .padding(.horizontal, 32)

                    // Error label
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 14)
                            .transition(.opacity.animation(.easeIn))
                    }

                    // knows to show MainTabView after successful login
                    Button(action: {
                        isLoggedInViaEmail = false  
                        goToLogin = true
                    }) {
                        Text("Use Email & Password instead")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#1DB954"))
                            .underline()
                    }
                    .padding(.top, 20)

                    Spacer()

                    Spacer().frame(height: 20)
                }

                .navigationDestination(isPresented: $goToLogin) {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authenticate()
                }
            }
        }
    }

    // Logo Row
    private var logoRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#1DB954"))
            Text("Mini Budget")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#1DB954"))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    //  Glow Icon Card
    private var glowIconCard: some View {
        ZStack {
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
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowScale = 1.18
                }
            }

            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .frame(width: 118, height: 118)
                .shadow(color: Color(hex: "#1DB954").opacity(0.18), radius: 20, x: 0, y: 6)

            CornerBrackets(armLength: 14)
                .stroke(
                    Color(hex: "#1DB954").opacity(0.55),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 84, height: 84)

            Image(systemName: "faceid")
                .font(.system(size: 46))
                .foregroundColor(Color(hex: "#1DB954"))

            sparkleStarBadge
                .offset(x: 44, y: -44)
        }
    }

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

    //  Unlock Button
    private var unlockButton: some View {
        Button(action: authenticate) {
            ZStack {
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#1DB954")))
                } else {
                    Text("LOOK AT YOUR DEVICE TO UNLOCK")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#1DB954"))
                        .tracking(0.5)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color(hex: "#1DB954"), lineWidth: 1.5))
        }
        .disabled(isAuthenticating)
    }

    //  Authentication
    private func authenticate() {
        errorMessage     = ""
        isAuthenticating = true

        let context = LAContext()
        var policyError: NSError?

        let hasBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &policyError
        )

        let policy: LAPolicy = hasBiometrics
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        context.evaluatePolicy(policy, localizedReason: "Unlock Mini Budget to view your savings.") { success, evalError in
            DispatchQueue.main.async {
                isAuthenticating = false

                if success {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onAuthenticated()
                    }
                } else {
                    if let error = evalError as? LAError {
                        switch error.code {
                        case .userCancel:
                            errorMessage = ""
                        case .userFallback:
                            authenticateWithPasscode()
                        case .biometryLockout:
                            errorMessage = "Face ID is locked. Use passcode or email login."
                            authenticateWithPasscode()
                        case .biometryNotEnrolled:
                            errorMessage = "Face ID not set up. Use email login below."
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

// CornerBrackets Shape
struct CornerBrackets: Shape {
    var armLength: CGFloat

    func path(in rect: CGRect) -> Path {
        var p    = Path()
        let minX = rect.minX, minY = rect.minY
        let maxX = rect.maxX, maxY = rect.maxY
        let a    = armLength

        p.move(to: CGPoint(x: minX, y: minY + a))
        p.addLine(to: CGPoint(x: minX, y: minY))
        p.addLine(to: CGPoint(x: minX + a, y: minY))

        p.move(to: CGPoint(x: maxX - a, y: minY))
        p.addLine(to: CGPoint(x: maxX, y: minY))
        p.addLine(to: CGPoint(x: maxX, y: minY + a))

        p.move(to: CGPoint(x: minX, y: maxY - a))
        p.addLine(to: CGPoint(x: minX, y: maxY))
        p.addLine(to: CGPoint(x: minX + a, y: maxY))

        p.move(to: CGPoint(x: maxX - a, y: maxY))
        p.addLine(to: CGPoint(x: maxX, y: maxY))
        p.addLine(to: CGPoint(x: maxX, y: maxY - a))

        return p
    }
}

#Preview {
    FaceIDView {
        print("Authenticated")
    }
}
