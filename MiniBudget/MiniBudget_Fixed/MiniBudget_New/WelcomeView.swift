//
//  WelcomeView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI

struct WelcomeView: View {

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // Piggy bank illustration
                Image("piggy_bank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(.bottom, 24)

                // Headline
                Text("Welcome to\nMini Budget !")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 40)

                // Primary button: Get Started → SignUpView
                NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                    PrimaryButton(title: "Get Started  →")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 12)

                // Log In → real LoginView (not SetGoalView)
                NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
                    OutlinedButton(title: "Log In  →")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 28)

                // Divider: Or Sign Up with
                OrDivider()
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)

                // Social sign-in buttons
                SocialSignInRow()
                    .padding(.bottom, 40)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack { WelcomeView() }
}
