//
//  ReminderView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//
import SwiftUI

struct SetReminderView: View {
    
    
    let userName: String
    let dailyAmount: Int
    let targetAmount: Int
    
    
    // Time the user picks for their daily reminder.
    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: Date()
    ) ?? Date()
    
    // Whether the user wants Daily or Weekly reminders.
    @State private var reminderFrequency: ReminderFrequency = .daily
    
    // Whether push notifications are enabled.
    @State private var pushNotificationsEnabled = true

    //Controls navigation to the All Set screen.
    @State private var goToAllSet = false
    
    
    enum ReminderFrequency: String, CaseIterable {
        case daily  = "Daily"
        case weekly = "Weekly"
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Back arrow
            backButton
                .padding(.top, 16)
                .padding(.horizontal, 24)
            
            // Page title
            Text("Set Reminder !")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)
            
            // SET TIME section
            sectionLabel("SET TIME")
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            
            // Time picker — shows as a text field with a clock icon
            timePicker
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            
            // SAVING GOAL TARGET frequency section
            sectionLabel("SAVING GOAL TARGET")
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            // Daily / Weekly segmented control styled a
            frequencyPicker
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            
            // Push Notifications toggle row
            pushNotificationRow
                .padding(.horizontal, 24)
            
            Spacer()
            
            // Set Reminder button
            Button(action: proceedToAllSet) {
                PrimaryButton(title: "Set Reminder")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
                .navigationDestination(isPresented: $goToAllSet) {
                    AllSetView(
                        userName: userName,
                        dailyAmount: dailyAmount,
                        targetAmount: targetAmount,
                        reminderTime: reminderTime,
                        reminderFrequency: reminderFrequency.rawValue
                    )
                    .navigationBarBackButtonHidden(true)
                }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    //Sub-views
    
    private var backButton: some View {
        Button(action: { /* NavigationStack pops automatically — handled by swipe or the navigation */ }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    //Small uppercase section label
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.gray)
            .tracking(1.2)
    }
    
    // Time picker displayed as a compact input field
    private var timePicker: some View {
        DatePicker(
            "",
            selection: $reminderTime,
            displayedComponents: .hourAndMinute   // Only show hour:minute, no date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        // Wrap in a grey rounded-rectangle field to match wireframe style
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // Daily / Weekly segmented toggle 
    private var frequencyPicker: some View {
        HStack(spacing: 0) {
            ForEach(ReminderFrequency.allCases, id: \.self) { freq in
                Button(action: { reminderFrequency = freq }) {
                    Text(freq.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(reminderFrequency == freq ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            reminderFrequency == freq
                                ? AppColors.primaryGreen
                                : Color(.systemGray6)
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // Push notifications toggle row with icon, title, subtitle, and iOS Toggle
    private var pushNotificationRow: some View {
        HStack(spacing: 14) {
            // Bell icon inside a grey circle
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            // Text stack
            VStack(alignment: .leading, spacing: 2) {
                Text("Push Notifications")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                Text("Instant alerts on your device")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $pushNotificationsEnabled)
                .tint(AppColors.primaryGreen)
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    
    // Saves settings and navigates to the All Set screen.
    private func proceedToAllSet() {
        
        
        goToAllSet = true
    }
}


#Preview {
    NavigationStack {
        SetReminderView(
            userName: "Erandi",
            dailyAmount: 50,
            targetAmount: 5000
        )
    }
}
