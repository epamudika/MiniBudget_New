//
//  AllSetView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//


import SwiftUI

struct AllSetView: View {
    
    
    let userName: String
    let dailyAmount: Int
    let targetAmount: Int
    let reminderTime: Date
    let reminderFrequency: String
    
    
    // Marks onboarding as complete in UserDefaults so this flow
    // never shows again after the user taps Start Saving.
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Back arrow
            backButton
                .padding(.top, 16)
                .padding(.horizontal, 24)
            
            Spacer()
            
            
            HStack {
                Spacer()
                Image("coin_hand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                Spacer()
            }
            .padding(.bottom, 24)
            
            // "You're All Set !!" headline
            Text("You're All Set !!")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)
            
            // Subtitle
            Text("Your piggy bank is ready to help\nyou grow your savings.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 28)
            
            // Goal Summary card
            GoalSummaryCard(
                userName: userName,
                dailyAmount: dailyAmount,
                targetAmount: targetAmount,
                reminderTime: reminderTime,
                reminderFrequency: reminderFrequency
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            //Start Saving button
            Button(action: startSaving) {
                PrimaryButton(title: "Start Saving")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    
    // Grey back arrow button
    private var backButton: some View {
        Button(action: {}) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    
    // Marks onboarding as complete and navigates to the main app.
    private func startSaving() {
       
        onboardingComplete = true
        
       
    }
}



struct GoalSummaryCard: View {
    
    let userName: String
    let dailyAmount: Int
    let targetAmount: Int
    let reminderTime: Date
    let reminderFrequency: String
    
    // Formatter for displaying the reminder time
    private var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: reminderTime)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Card title
            Text("Goal Summary")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.bottom, 14)
            
            // Divider line
            Divider().padding(.bottom, 12)
            
            // Name row
            summaryRow(label: "Name",         value: userName.isEmpty ? "—" : userName)
            
            // Daily saving row
            summaryRow(label: "Daily saving", value: "Rs. \(dailyAmount)")
            
            // Savings target row
            summaryRow(label: "Target",       value: "Rs. \(targetAmount)")
            
            // Reminder row
            summaryRow(label: "Reminder",     value: "\(timeString) · \(reminderFrequency)")
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    //  Helper: one label + value row
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.bottom, 10)
    }
}


#Preview {
    NavigationStack {
        AllSetView(
            userName: "Erandi",
            dailyAmount: 50,
            targetAmount: 5000,
            reminderTime: Date(),
            reminderFrequency: "Daily"
        )
    }
}
