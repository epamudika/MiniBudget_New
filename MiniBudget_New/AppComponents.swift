//
//  AppComponents.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//
import SwiftUI

struct PrimaryButton: View {
    let title: String
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct OutlinedButton: View {
    let title: String
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
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
            Text("Google").padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
            Text("Apple").padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OnboardingTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .keyboardType(keyboardType)
    }
}

struct AppColors {
    static let primaryGreen = Color.green
}
