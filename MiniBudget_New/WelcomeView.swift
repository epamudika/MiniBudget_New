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
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                Image("Mini Pig Bank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(.bottom, 24)
                
                Text("Welcome to\nMini Budget !")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 40)
                
                PrimaryButton(title: "Get Started →")
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)
                
                OutlinedButton(title: "Log In →")
                    .padding(.horizontal, 32)
                    .padding(.bottom, 28)
                
                OrDivider()
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
                
                SocialSignInRow()
                    .padding(.bottom, 40)
                
                Spacer()
            }
        }
    }
}


#Preview {
    WelcomeView()
}

