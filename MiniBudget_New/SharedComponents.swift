//
//  SharedComponents.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-07.
//


import SwiftUI



enum AppColors {
    
    /// The main brand green used for buttons, selected chips, toggles.
    /// Matches the green shown across all wireframe screens.
    static let primaryGreen = Color(red: 0.18, green: 0.80, blue: 0.44)   // #2ECC71-style
    
    /// A lighter green tint used for progress bars and backgrounds.
    static let lightGreen   = Color(red: 0.18, green: 0.80, blue: 0.44).opacity(0.12)
    
    /// Standard label grey used for section headers and placeholders.
    static let labelGrey    = Color(.systemGray)
    
    /// Card / field background — very light grey.
    static let fieldBG      = Color(.systemGray6)
}




struct PrimaryButton: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)          // Full width
            .frame(height: 52)                   // Fixed height matches wireframe
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
    var keyboardType: UIKeyboardType      = .default
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



struct OrDivider: View {
    
    var body: some View {
        HStack(spacing: 12) {
            // Left line
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            // Centre label
            Text("Or Sign Up with")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .fixedSize()        // Prevents text from wrapping
            
            // Right line
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
}




struct SocialSignInRow: View {
    
    var body: some View {
        HStack(spacing: 20) {
            // Google button
            SocialButton(iconName: "g.circle.fill",    color: Color(red: 0.85, green: 0.27, blue: 0.22))
            
            // Apple button
            SocialButton(iconName: "apple.logo",       color: .black)
        }
        .frame(maxWidth: .infinity)  // Centre the row
    }
}

/// One circular social sign-in button.
private struct SocialButton: View {
    
    let iconName: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // In production: trigger Google/Apple Sign-In SDK here
        }) {
            ZStack {
                // White circle with grey border
                Circle()
                    .fill(Color.white)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
        }
    }
}




struct LoginView: View {
    
    @State private var email    = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text("Welcome back")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 60)
                .padding(.bottom, 8)
            
            Text("Log in to Mini Budget")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.bottom, 36)
            
            VStack(spacing: 12) {
                OnboardingTextField(
                    placeholder: "Email Address",
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
                
                // Password field — uses SecureField for hidden input
                SecureField("Password", text: $password)
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(AppColors.fieldBG)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Log In button — in production trigger Firebase Auth here
            Button(action: {}) {
                PrimaryButton(title: "Log In")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}


#Preview("PrimaryButton") {
    PrimaryButton(title: "Get Started →")
        .padding()
}

#Preview("OnboardingTextField") {
    OnboardingTextField(placeholder: "Full Name", text: .constant(""))
        .padding()
}
