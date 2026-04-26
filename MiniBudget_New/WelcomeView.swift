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


struct PrimaryButton: View {
    let title: String
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

struct OutlinedButton: View {
    let title: String
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: 2)
            )
            .foregroundColor(.green)
    }
}

struct OrDivider: View {
    var body: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
            Text("OR").padding(.horizontal, 8).foregroundColor(.gray)
            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
        }
    }
}

struct SocialSignInRow: View {
    var body: some View {
        HStack(spacing: 20) {
            // Placeholder buttons
            Button(action: {}) { Text("Google").padding().background(Color.gray.opacity(0.1)).cornerRadius(8) }
            Button(action: {}) { Text("Apple").padding().background(Color.gray.opacity(0.1)).cornerRadius(8) }
        }
    }
}

#Preview {
    WelcomeView()
}
