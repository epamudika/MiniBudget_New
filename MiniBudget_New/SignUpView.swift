//
//  SignUpView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//
import SwiftUI

struct SignUpView: View {
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("IDENTITY")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                    .tracking(1.5)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                
                VStack(spacing: 12) {
                    OnboardingTextField(placeholder: "Full Name", text: $fullName, keyboardType: .default)
                    OnboardingTextField(placeholder: "Email Address", text: $email, keyboardType: .emailAddress)
                    OnboardingTextField(placeholder: "Phone Number", text: $phone, keyboardType: .phonePad)
                }
                .padding(.horizontal, 24)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }
                
                Button(action: validateAndProceed) {
                    PrimaryButton(title: "Get Started →")
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                OrDivider()
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 20)
                
                SocialSignInRow()
                
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        print("Navigate to Login")
                    }) {
                        Text("Login")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
    
    private func validateAndProceed() {
        errorMessage = ""
        
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter your full name."
            return
        }
        
        if !(email.contains("@") && email.contains(".")) {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        let digitsOnly = phone.filter { $0.isNumber }
        if digitsOnly.count < 7 {
            errorMessage = "Please enter a valid phone number."
            return
        }
        
        print("Validation successful. Ready for next screen.")
    }
}

#Preview {
    SignUpView()
}
