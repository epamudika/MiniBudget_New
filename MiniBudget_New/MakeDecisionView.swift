//
//  MakeDecisionView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.


import SwiftUI

// MakeDecisionView

struct MakeDecisionView: View {

    // Input data from the previous CountDownView
    // These values are passed forward from AddPurchaseView
    // via CountDownView using NavigationLink parameters.

    // Name of the item the user was considering buying.
    let itemName        : String

    // Price in rupees the user entered.
    let price           : Double

    //Spending category (Leisure / Essentials / Travel).
    let category        : String

    // How many days faster the goal would be reached by saving.
    // Calculated from (price / dailyGoal) in production.
    let goalFasterDays  : Int

    //The savings goal name to reference in the card body text.
    let goalName        : String

    // Growth potential percentage shown on the card (e.g. "+4.2%").
    let growthPotential : String

    // Convenience initialiser with wireframe defaults
    init(
        itemName        : String = "Snack Pack",
        price           : Double = 500,
        category        : String = "Instant Food",
        goalFasterDays  : Int    = 12,
        goalName        : String = "New Car",
        growthPotential : String = "+4.2%"
    ) {
        self.itemName        = itemName
        self.price           = price
        self.category        = category
        self.goalFasterDays  = goalFasterDays
        self.goalName        = goalName
        self.growthPotential = growthPotential
    }

    // Environment
    //Provided by NavigationStack — used by the ← back button.
    @Environment(\.dismiss) private var dismiss

    // MARK: - Navigation state
    // Triggers navigation to SaveSuccessView when true.
    @State private var goToSaveSuccess : Bool = false

    // Triggers navigation to BuyConfirmView when true.
    @State private var goToBuyConfirm  : Bool = false

    // Body
    var body: some View {
        ZStack {

            // Full-screen white background
            Color.white.ignoresSafeArea()

            // Main scrollable content column
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    //Back navigation row
                    backNavRow
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 22)

                    // "What Do You Want?" headline + subtitle
                    headlineSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 22)

                    // "Save Instead" green recommendation card
                    saveInsteadCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                    // "Buy Item Anyway" secondary option row
                    buyItemAnyway
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)

                    // "Save the Money" primary CTA button
                    saveTheMoneyButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }

            // Programmatic NavigationLinks
            
            NavigationLink(
                destination: SaveSuccessView(
                    itemName : itemName,
                    price    : price,
                    goalName : goalName
                ).navigationBarHidden(true),
                isActive: $goToSaveSuccess
            ) { EmptyView() }

            NavigationLink(
                destination: BuyConfirmView(
                    itemName: itemName,
                    price   : price
                ).navigationBarHidden(true),
                isActive: $goToBuyConfirm
            ) { EmptyView() }
        }
        .navigationBarHidden(true)
    }


    // Back navigation row
    // "← Decision Timer"
    private var backNavRow: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text("Decision Timer")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color(hex: "#1A1A1A"))
        }
    }


    // Headline + subtitle
    
    private var headlineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Main headline
            Text("What Do You Want?")
                .font(.system(size: 26, weight: .black))
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            // Subheadline using HStack to avoid the + warning and initializer error
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                // First part of the sentence
                Text("Your cooling-off period has expired.\nHow should we proceed with this ")
                    .foregroundColor(Color(hex: "#9E9E9E"))
                
                // The price part
                Text("Rs. \(Int(price))")
                    .foregroundColor(Color(hex: "#1DB954"))
                    .fontWeight(.bold)
                
                // The closing question mark
                Text("?")
                    .foregroundColor(Color(hex: "#9E9E9E"))
            }
            .font(.system(size: 14))
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // "Save Instead" card ─────────────────────────
    
    private var saveInsteadCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            //  Dark green badge pill
            
            HStack {
                Spacer()
                Text("GOAL REACHED \(goalFasterDays) DAYS FASTER!")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white)
                    .tracking(0.6)
                    .padding(.vertical, 7)
                Spacer()
            }
            .background(Color(hex: "#1B5E20"))   // Dark forest green
            // Round only the top-left and top-right corners
            .cornerRadius(12, corners: [.topLeft, .topRight])

            // Card body
            VStack(alignment: .leading, spacing: 12) {

                // Row: leaf icon + "Save Instead" title
                HStack(spacing: 14) {

                    // White circle with leaf icon (subtle shadow)
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .shadow(
                                color: Color.black.opacity(0.08),
                                radius: 6, x: 0, y: 2
                            )
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#1DB954"))
                    }

                    // "Save Instead" bold title
                    Text("Save Instead")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }

                // Description grey text
                Text("Boost your '\(goalName)' goal by adding this amount to your vault.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                // Green "Growth Potential" line
                Text("Growth Potential: \(growthPotential)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1DB954"))
            }
            .padding(16)
            .background(Color(hex: "#E8F5E9"))   // Mint green body
            // Round only the bottom two corners
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
        // Green border stroke around the entire card
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#1DB954"), lineWidth: 1.5)
        )
        .shadow(color: Color(hex: "#1DB954").opacity(0.1), radius: 8, x: 0, y: 2)
    }


    // "Buy Item Anyway" row ───────────────────────
 
    private var buyItemAnyway: some View {
        Button(action: { goToBuyConfirm = true }) {
            HStack(spacing: 14) {

                // Grey bag icon circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "#F0F0F0"))
                        .frame(width: 42, height: 42)
                    Image(systemName: "bag.fill")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }

                // Label
                Text("Buy Item Anyway")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1A"))

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#BDBDBD"))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }


    // "Save the Money" button
    
    private var saveTheMoneyButton: some View {
        Button(action: { goToSaveSuccess = true }) {
            Text("Save the Money")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#1DB954"))
                .cornerRadius(14)
        }
    }
}


//cornerRadius(_:corners:) helper


extension View {
    // Rounds only the specified corners by the given radius.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(SpecificCornersShape(radius: radius, corners: corners))
    }
}

// Custom Shape that rounds only specified corners.
private struct SpecificCornersShape: Shape {
    let radius  : CGFloat
    let corners : UIRectCorner

    func path(in rect: CGRect) -> Path {
        // UIBezierPath handles the specific-corner rounding logic.
        let bezier = UIBezierPath(
            roundedRect      : rect,
            byRoundingCorners: corners,
            cornerRadii      : CGSize(width: radius, height: radius)
        )
        return Path(bezier.cgPath)
    }
}


//  SaveSuccessView — shown after "Save the Money"


struct SaveSuccessView: View {

    let itemName : String
    let price    : Double
    let goalName : String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Celebration checkmark icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#E8F5E9"))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(Color(hex: "#1DB954"))
                }

                // Headline
                Text("Great Choice! 🎉")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(Color(hex: "#1A1A1A"))

                // Body text
                Text("Rs. \(Int(price)) has been added to your '\(goalName)' savings vault.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(3)

                Spacer()

                // Back to Home button
                Button(action: { dismiss() }) {
                    Text("Back to Home")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#1DB954"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}


// BuyConfirmView — shown after "Buy Item Anyway"


struct BuyConfirmView: View {

    let itemName : String
    let price    : Double

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Bag icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFF8E1"))
                        .frame(width: 100, height: 100)
                    Image(systemName: "bag.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "#F5A623"))
                }

                Text("Purchase Logged")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(Color(hex: "#1A1A1A"))

                Text("\(itemName) — Rs. \(Int(price)) has been recorded.\nTry saving next time! 💪")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(3)

                Spacer()

                Button(action: { dismiss() }) {
                    Text("Back to Home")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#F5A623"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}



#Preview("Make Decision") {
    NavigationStack {
        MakeDecisionView(
            itemName       : "Snack Pack",
            price          : 500,
            category       : "Instant Food",
            goalFasterDays : 12,
            goalName       : "New Car",
            growthPotential: "+4.2%"
        )
    }
}
