//
//  AppTheme.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.

import SwiftUI

enum AppTheme {

    //Greens
    // Primary action green — buttons, selected chips, chart bars
    static let primaryGreen   = Color(hex: "#1DB954")

    // Lighter green — streak banner gradient start
    static let lightGreen     = Color(hex: "#4CAF50")

    // Very pale green — card tints, calendar cell backgrounds
    static let paleGreen      = Color(hex: "#E8F5E9")

    // Dark forest green — Savings Performance card background
    static let darkGreen      = Color(hex: "#0A3D2B")

    // Medium green — calendar today highlight, active tab icon
    static let midGreen       = Color(hex: "#2E7D32")

    // Neutrals
    // Page/screen background
    static let background     = Color(hex: "#F7F7F7")

    // White card surface
    static let cardWhite      = Color.white

    // Light grey card (History stats, Goal card)
    static let cardGrey       = Color(hex: "#F5F5F5")

    // Primary text — almost black
    static let textPrimary    = Color(hex: "#1A1A1A")

    //Secondary text — dark grey
    static let textSecondary  = Color(hex: "#555555")

    //Placeholder / caption text — medium grey
    static let textCaption    = Color(hex: "#9E9E9E")

    // Accent
    // Gold / Amber used on badge chips
    static let gold           = Color(hex: "#F5A623")

    //Locked badge grey
    static let lockedGrey     = Color(hex: "#BDBDBD")

    //Tab bar
    static let tabBarBG       = Color.white
    static let tabActive      = Color(hex: "#1DB954")
    static let tabInactive    = Color(hex: "#9E9E9E")
}

// Allows writing Color(hex: "#1DB954") anywhere in the project.
extension Color {
    init(hex: String) {
        // Strip leading # if present
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 14
    var padding: CGFloat      = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardWhite)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// Small uppercase grey label used above sections.
struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(AppTheme.textCaption)
            .tracking(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum MBTab: Int, CaseIterable {
    case home      = 0
    case history   = 1
    case calendar  = 2
    case decision  = 3   
    case rewards   = 4

    var label: String {
        switch self {
        case .home:     return "Home"
        case .history:  return "History"
        case .calendar: return "Calendar"
        case .decision: return "Decision"  
        case .rewards:  return "Rewards"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .history:  return "chart.bar.fill"
        case .calendar: return "calendar"
        case .decision: return "brain.head.profile" 
        case .rewards:  return "star.fill"
        }
    }
}
