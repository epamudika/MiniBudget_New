//
//  GoalSetupView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI

struct SetGoalView: View {
    
    
    // User's name passed from SignUpView 
    let userName: String
    
    
    // Currently selected daily saving amount in rupees.
    @State private var selectedDailyAmount: Int = 20
    
    //Currently selected savings target in rupees.
    @State private var selectedTargetAmount: Int = 500
    
    // Available daily amount options shown as chips.
    private let dailyAmountOptions = [20, 30, 40, 50]
    
    // Available savings target options shown as chips.
    private let targetAmountOptions = [500, 1000, 1500, 2000]
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Page title
                Text("Set Your Goal !")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)
                
                // Daily Amount section
                sectionLabel("Daily Amount")
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                Text("How much can you comfortably set aside each day?")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                
                // 2×2 grid of daily amount chips
                GoalChipGrid(
                    options: dailyAmountOptions,
                    selected: $selectedDailyAmount,
                    prefix: "Rs."
                )
                .padding(.horizontal, 24)
                
                //  Savings Goal Target section
                sectionLabel("Savings Goal Target")
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                
                Text("What is your ultimate financial milestone for this plan?")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                
                // 2×2 grid of target chips
                GoalChipGrid(
                    options: targetAmountOptions,
                    selected: $selectedTargetAmount,
                    prefix: "Rs."
                )
                .padding(.horizontal, 24)
                
                // Set Reminder button
                NavigationLink(
                    destination: SetReminderView(
                        userName: userName,
                        dailyAmount: selectedDailyAmount,
                        targetAmount: selectedTargetAmount
                    ).navigationBarBackButtonHidden(true)
                ) {
                    PrimaryButton(title: "Start Saving  →")
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.black)
    }
}




private struct GoalChipGrid: View {
    
    let options: [Int]
    @Binding var selected: Int
    let prefix: String
    
    // Two chips per row
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options, id: \.self) { amount in
                GoalChip(
                    amount: amount,
                    prefix: prefix,
                    isSelected: selected == amount,
                    onTap: { selected = amount }
                )
            }
        }
    }
}




private struct GoalChip: View {
    
    let amount: Int
    let prefix: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                // Small "AMOUNT" label at the top-left of the chip
                Text("AMOUNT")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                    .tracking(0.8)
                
                // The rupee amount in bold
                Text("\(prefix) \(amount)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.primaryGreen : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? AppColors.primaryGreen : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }
}


#Preview {
    NavigationStack {
        SetGoalView(userName: "Erandi")
    }
}
