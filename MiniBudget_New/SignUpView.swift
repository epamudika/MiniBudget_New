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
    
    
    @State private var goToSetGoal = false
    
    // Validation error message shown below the form.
    @State private var errorMessage = ""
    
    //Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                //  Section label: IDENTITY
                Text("IDENTITY")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                    .tracking(1.5)              // Letter spacing
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                
                // Input fields
                VStack(spacing: 12) {
                    
                    // Full Name field
                    OnboardingTextField(
                        placeholder: "Full Name",
                        text: $fullName,
                        keyboardType: .default,
                        //autocapitalization: .words
                    )
                    
                    // Email field — uses email keyboard
                    OnboardingTextField(
                        placeholder: "Email Address",
                        text: $email,
                        keyboardType: .emailAddress,
                        //autocapitalization: .never
                    )
                    
                    // Phone number field — uses phone keyboard
                    OnboardingTextField(
                        placeholder: "Phone Number",
                        text: $phone,
                        keyboardType: .phonePad,
                        //autocapitalization: .never
                    )
                }
                .padding(.horizontal, 24)
                
                //  Validation error (shown only when non-empty)
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }
                
                //  Get Started button
                Button(action: validateAndProceed) {
                    PrimaryButton(title: "Get Started  →")
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                //  Or Sign Up with divider
                OrDivider()
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 20)
                
                //  Social buttons
                SocialSignInRow()
                
                //  Already have an account link
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    NavigationLink(destination: GoalSetupView(userName: fullName).navigationBarBackButtonHidden(true)) {
                        Text("Login")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                
                // Triggered when goToSetGoal becomes true after validation
                NavigationLink(
                    destination: GoalSetupView(userName: fullName).navigationBarBackButtonHidden(true),
                    isActive: $goToSetGoal
                ) { EmptyView() }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    //Validation
    
    // Validates all fields before navigating to the next screen.
    private func validateAndProceed() {
        // Reset previous error
        errorMessage = ""
        
        //Check full name is not empty
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your full name."
            return
        }
        
        // Basic email format check
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        // Phone must be at least 7 digits
        let digitsOnly = phone.filter { $0.isNumber }
        guard digitsOnly.count >= 7 else {
            errorMessage = "Please enter a valid phone number."
            return
        }
        
        // All good — proceed
        goToSetGoal = true
    }
}


#Preview {
    NavigationStack {
        SignUpView()
    }
}

