//
//  SharedComponents.swift
//  MiniBudget_New
//  Created by Erandi Pathirana on 2026-04-26.

import SwiftUI
import UIKit

enum AppColors {
    static let primaryGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let lightGreen   = Color(red: 0.18, green: 0.80, blue: 0.44).opacity(0.12)
    static let labelGrey    = Color(.systemGray)
    static let fieldBG      = Color(.systemGray6)
}

struct PrimaryButton: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppColors.primaryGreen)
            .cornerRadius(14)
    }
}

struct OutlinedButton: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppColors.primaryGreen)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.primaryGreen, lineWidth: 1.5)
            )
    }
}

struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 15))
            .foregroundColor(.black)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(AppColors.fieldBG)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct OnboardingPasswordField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .font(.system(size: 15))
            .foregroundColor(.black)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(AppColors.fieldBG)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct OrDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
            Text("Or Sign Up with")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .fixedSize()
            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
        }
    }
}

struct SocialSignInRow: View {
    var body: some View {
        HStack(spacing: 20) {
            SocialButton(iconName: "g.circle.fill", color: Color(red: 0.85, green: 0.27, blue: 0.22))
            SocialButton(iconName: "apple.logo",    color: .black)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SocialButton: View {
    let iconName: String
    let color: Color
    var body: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
        }
    }
}

// LoginView (Firebase)
struct LoginView: View {
    @State private var email        = ""
    @State private var password     = ""
    @State private var goToMain     = false
    @State private var errorMessage = ""
    @AppStorage("onboardingComplete")  private var onboardingComplete  = false
    @AppStorage("isLoggedInViaEmail")  private var isLoggedInViaEmail  = false
    @ObservedObject private var firebase = FirebaseManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("WELCOME BACK")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                        .tracking(1.5)
                    Text("Log In")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Section label
                Text("YOUR ACCOUNT")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                    .tracking(1.5)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                // Input fields
                VStack(spacing: 12) {
                    OnboardingTextField(
                        placeholder: "Email Address",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    OnboardingPasswordField(
                        placeholder: "Password",
                        text: $password
                    )
                }
                .padding(.horizontal, 24)

                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                // Log In button
                Button(action: doLogin) {
                    if firebase.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppColors.primaryGreen)
                        .cornerRadius(14)
                    } else {
                        PrimaryButton(title: "Log In  →")
                    }
                }
                .disabled(firebase.isLoading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Divider
                OrDivider()
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                SocialSignInRow()

                // Don't have an account?
                HStack {
                    Spacer()
                    Text("Don't have an account?")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    NavigationLink(
                        destination: SignUpView()
                            .navigationBarBackButtonHidden(true)
                    ) {
                        Text("Sign Up")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 40)

                .onChange(of: goToMain) { newVal in
                    if newVal {
                        // isLoggedInViaEmail already set in doLogin 
                    }
                }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func doLogin() {
        errorMessage = ""
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        firebase.logIn(email: email, password: password) { success in
            if success {
                onboardingComplete = true
                // Tell ContentView to skip Face ID and show MainTabView
                isLoggedInViaEmail = true
                goToMain = true
            } else {
                errorMessage = firebase.errorMessage.isEmpty
                    ? "Login failed. Please check your email and password."
                    : firebase.errorMessage
            }
        }
    }
}
