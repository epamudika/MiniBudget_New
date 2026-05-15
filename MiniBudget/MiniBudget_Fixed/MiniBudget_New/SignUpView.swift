//
//  SignUpView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//
import SwiftUI

struct SignUpView: View {

    @State private var fullName    = ""
    @State private var email       = ""
    @State private var phone       = ""
    @State private var password    = ""

    // Navigate to goal setup after successful sign-up
    @State private var goToSetGoal = false

    // Local validation / Firebase error message
    @State private var errorMessage = ""

    @AppStorage("onboardingComplete") private var onboardingComplete = false

    // Firebase singleton
    @ObservedObject private var firebase = FirebaseManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                //  Section label: IDENTITY
                Text("IDENTITY")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                    .tracking(1.5)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                // Input fields
                VStack(spacing: 12) {
                    OnboardingTextField(
                        placeholder: "Full Name",
                        text: $fullName,
                        keyboardType: .default,
                        autocapitalization: .words
                    )
                    OnboardingTextField(
                        placeholder: "Email Address",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    OnboardingTextField(
                        placeholder: "Phone Number",
                        text: $phone,
                        keyboardType: .phonePad,
                        autocapitalization: .never
                    )
                    OnboardingPasswordField(
                        placeholder: "Password",
                        text: $password
                    )
                }
                .padding(.horizontal, 24)

                //  Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                //  Get Started button
                Button(action: validateAndProceed) {
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
                        PrimaryButton(title: "Get Started  →")
                    }
                }
                .disabled(firebase.isLoading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                //  Or Sign Up with divider
                OrDivider()
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                SocialSignInRow()

                //  Already have an account
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    NavigationLink(
                        destination: LoginView()
                            .navigationBarBackButtonHidden(true)
                    ) {
                        Text("Login")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 40)

                // Hidden navigation trigger
                .navigationDestination(isPresented: $goToSetGoal) {
                    SetGoalView(userName: fullName)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    //  Validation + Firebase sign-up
    private func validateAndProceed() {
        errorMessage = ""

        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your full name."
            return
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        let digits = phone.filter { $0.isNumber }
        guard digits.count >= 7 else {
            errorMessage = "Please enter a valid phone number."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        // Firebase sign-up
        firebase.signUp(fullName: fullName,
                        email: email,
                        phone: phone,
                        password: password) { success in
            if success {
                onboardingComplete = false   
                goToSetGoal = true
            } else {
                errorMessage = firebase.errorMessage
            }
        }
    }
}

#Preview {
    NavigationStack { SignUpView() }
}
