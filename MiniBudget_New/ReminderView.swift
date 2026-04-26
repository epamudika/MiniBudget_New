//
//  ReminderView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//
import SwiftUI


struct ReminderView: View {
    
    let userName: String
    let dailyAmount: Int
    let targetAmount: Int
    
    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: Date()
    ) ?? Date()
    
    @State private var reminderFrequency: ReminderFrequency = .daily
    @State private var pushNotificationsEnabled = true
    
    enum ReminderFrequency: String, CaseIterable {
        case daily  = "Daily"
        case weekly = "Weekly"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            backButton
                .padding(.top, 16)
                .padding(.horizontal, 24)
            
            Text("Set Reminder !")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)
            
            sectionLabel("SET TIME")
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            
            timePicker
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            
            sectionLabel("SAVING GOAL TARGET")
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            frequencyPicker
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            
            pushNotificationRow
                .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                print("Reminder set for \(reminderTime) at \(reminderFrequency.rawValue) frequency.")
            }) {
                PrimaryButton(title: "Set Reminder")
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
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.gray)
            .tracking(1.2)
    }
    
    private var timePicker: some View {
        DatePicker(
            "",
            selection: $reminderTime,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.compact)
        .labelsHidden()
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
    
    private var frequencyPicker: some View {
        HStack(spacing: 0) {
            ForEach(ReminderFrequency.allCases, id: \.self) { freq in
                Button(action: { reminderFrequency = freq }) {
                    Text(freq.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(reminderFrequency == freq ? .white : .primary)
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
    
    private var pushNotificationRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Push Notifications")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
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
}



#Preview {
    ReminderView(
        userName: "Erandi",
        dailyAmount: 50,
        targetAmount: 5000
    )
}
