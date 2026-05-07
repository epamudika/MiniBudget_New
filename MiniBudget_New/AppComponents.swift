//
//  AppComponents.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//
import SwiftUI

struct PrimaryButton: View {
    let title: String
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct OutlinedButton: View {
    let title: String
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
            .foregroundColor(.green)
    }
}

struct OrDivider: View {
    var body: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
            Text("OR").padding(.horizontal, 8).foregroundColor(.gray)
            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
        }
    }
}

struct SocialSignInRow: View {
    var body: some View {
        HStack(spacing: 20) {
            Text("Google").padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
            Text("Apple").padding().background(Color.gray.opacity(0.1)).cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OnboardingTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .keyboardType(keyboardType)
    }
}

struct AppColors {
    static let primaryGreen = Color.green
}


//Unified Theme
struct AppTheme {
    static let background = Color(red: 0.98, green: 0.99, blue: 0.98)
    static let primaryGreen = Color(red: 0.13, green: 0.58, blue: 0.29)
    static let lightGreen = Color(red: 0.40, green: 0.80, blue: 0.50)
    static let paleGreen = Color(red: 0.90, green: 0.96, blue: 0.92)
    static let cardWhite = Color.white
    static let cardGrey = Color(red: 0.94, green: 0.95, blue: 0.94)
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    static let textCaption = Color.gray.opacity(0.8)
    static let midGreen = Color(red: 0.34, green: 0.70, blue: 0.45) // For saved days
    static let darkGreen = Color(red: 0.08, green: 0.38, blue: 0.19) // For performance card
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let lockedGrey = Color(red: 0.80, green: 0.82, blue: 0.81)
}

struct HistoryBar: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

struct GoalModel {
    let dailyAmount: Double
    let totalSaved: Double
    let bestDayAmount: Double
    let daysLogged: Int
    let remainingBalance: Double
}

// Centralized Mock Data
struct MockData {
    static let goal = GoalModel(
        dailyAmount: 500,
        totalSaved: 3000,
        bestDayAmount: 500,
        daysLogged: 27,
        remainingBalance: 2500
    )
    
    static let weeklyBars: [HistoryBar] = [
        HistoryBar(label: "Mon", amount: 200),
        HistoryBar(label: "Tue", amount: 350),
        HistoryBar(label: "Wed", amount: 150),
        HistoryBar(label: "Thu", amount: 500),
        HistoryBar(label: "Fri", amount: 300),
        HistoryBar(label: "Sat", amount: 450),
        HistoryBar(label: "Sun", amount: 100)
    ]
    static let savedDaysInMonth: Set<Int> = [1, 2, 4, 5, 7, 8, 9, 12, 14, 15, 18, 20, 21]
    
    static let badges: [BadgeItem] = [
        BadgeItem(name: "Starter", description: "Saved your first Rs.100", icon: "leaf.fill", color: "4CAF50", isEarned: true),
        BadgeItem(name: "Consistent", description: "5 day saving streak", icon: "bolt.fill", color: "FF9800", isEarned: true),
        BadgeItem(name: "Halfway", description: "Reached 50% of monthly goal", icon: "star.fill", color: "2196F3", isEarned: true),
        BadgeItem(name: "Pro Saver", description: "Saved for 20 days straight", icon: "trophy.fill", color: "9C27B0", isEarned: false),
        BadgeItem(name: "Big Spender", description: "Actually, Big Saver!", icon: "crown.fill", color: "FFD700", isEarned: false),
        BadgeItem(name: "Final Boss", description: "Complete the full month", icon: "flag.checkered", color: "F44336", isEarned: false)
    ]
}

struct BadgeItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: String // Hex string
    let isEarned: Bool
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}




