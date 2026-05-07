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
    
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            backButton
                .padding(.top, 16)
                .padding(.horizontal, 24)
            
            Spacer()
            
            HStack {
                Spacer()
                Image("img_allSet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
            .padding(.bottom, 24)
            
            Text("You're All Set !!")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)
            
            Text("Your piggy bank is ready to help\nyou grow your savings.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 28)
            
            GoalSummaryCard(
                userName: userName,
                dailyAmount: dailyAmount,
                targetAmount: targetAmount,
                reminderTime: reminderTime,
                reminderFrequency: reminderFrequency
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: startSaving) {
                PrimaryButton(title: "Start Saving")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
    
    private var backButton: some View {
        Button(action: {
            print("Back tapped")
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
    
    private func startSaving() {
        onboardingComplete = true
        print("Onboarding complete. Navigating to main dashboard.")
    }
}

struct GoalSummaryCard: View {
    let userName: String
    let dailyAmount: Int
    let targetAmount: Int
    let reminderTime: Date
    let reminderFrequency: String
    
    private var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: reminderTime)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Goal Summary")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.bottom, 14)
            
            Divider().padding(.bottom, 12)
            
            summaryRow(label: "Name", value: userName.isEmpty ? "—" : userName)
            summaryRow(label: "Daily saving", value: "Rs. \(dailyAmount)")
            summaryRow(label: "Target", value: "Rs. \(targetAmount)")
            summaryRow(label: "Reminder", value: "\(timeString) · \(reminderFrequency)")
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
    
    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.bottom, 10)
    }
}



#Preview {
    AllSetView(
        userName: "Erandi",
        dailyAmount: 50,
        targetAmount: 5000,
        reminderTime: Date(),
        reminderFrequency: "Daily"
    )
}
