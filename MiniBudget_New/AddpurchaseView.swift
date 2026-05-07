//
//  AddpurchaseView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//



import SwiftUI

// Category enum
// Three spending categories shown as chip buttons.
enum PurchaseCategory: String, CaseIterable {
    case leisure    = "Leisure"
    case essentials = "Essentials"
    case travel     = "Travel"
}

//AddPurchaseView
struct AddPurchaseView: View {

    // State (form fields)
    @State private var itemName      : String           = ""
    @State private var priceText     : String           = ""
    @State private var selectedCat   : PurchaseCategory = .leisure  // Default = Leisure (green)

    // Navigation state
    //Set to true when "Start Decision" is tapped + validated.
    // Triggers the NavigationLink to CountDownView.
    @State private var goToCountdown : Bool = false

    // Validation error
    @State private var errorMessage  : String = ""

    // Computed price
    private var priceDouble: Double { Double(priceText) ?? 0 }

    // Body
    var body: some View {
        ZStack(alignment: .bottom) {

            // Scrollable form content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Spacer().frame(height: 32)

                    //Headline
                    Text("Add Purchase Idea!")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)

                    //Italic green subtitle
                    Text("Think before you buy!")
                        .font(.system(size: 14, weight: .regular))
                        .italic()
                        .foregroundColor(Color(hex: "#1DB954"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 32)

                    // ITEM NAME field
                    fieldLabel("ITEM NAME")
                    itemNameField
                        .padding(.bottom, 20)

                    //  PRICE field
                    fieldLabel("PRICE")
                    priceField
                        .padding(.bottom, 20)

                    //CATEGORY chips
                    fieldLabel("CATEGORY")
                    categoryChips
                        .padding(.bottom, 32)

                    //Validation error (visible when non-empty)
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 2)
                            .padding(.bottom, 12)
                    }

                    // Start Decision button
                    startButton

                    // Hidden NavigationLink, triggered programmatically
                    NavigationLink(
                        destination: CountDownView(
                            itemName:  itemName,
                            price:     priceDouble,
                            category:  selectedCat.rawValue
                        )
                        .navigationBarHidden(true),
                        isActive: $goToCountdown
                    ) { EmptyView() }

                    Spacer().frame(height: 100)   // Clear tab bar
                }
                .padding(.horizontal, 24)
            }
            .background(Color.white.ignoresSafeArea())

            //Custom tab bar
            AddPurchaseTabBar()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }


    // Small uppercase field label
    
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(Color(hex: "#9E9E9E"))
            .tracking(0.8)
            .padding(.bottom, 6)
    }


    // Item name text field
    // Light green-tinted rounded field with placeholder "eg: Snacks".
    private var itemNameField: some View {
        TextField("eg: Snacks", text: $itemName)
            .font(.system(size: 15))
            .foregroundColor(Color(hex: "#1A1A1A"))
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color(hex: "#F0FFF4"))         // Very pale green tint
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#C8E6C9"), lineWidth: 1)   // Light green border
            )
    }


    // Price text field
    // Same pale-green style, keyboard is decimal pad.
    // Shows "Rs." prefix inside the field.
    private var priceField: some View {
        HStack(spacing: 4) {
            Text("Rs.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#9E9E9E"))
            TextField("500.00", text: $priceText)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#1A1A1A"))
                .keyboardType(.decimalPad)
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color(hex: "#F0FFF4"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#C8E6C9"), lineWidth: 1)
        )
    }


    // Category chips
    
    private var categoryChips: some View {
        HStack(spacing: 10) {
            ForEach(PurchaseCategory.allCases, id: \.self) { cat in
                Button(action: { selectedCat = cat }) {
                    Text(cat.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedCat == cat ? .white : Color(hex: "#1A1A1A"))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            selectedCat == cat
                                ? Color(hex: "#1DB954")
                                : Color.white
                        )
                        .cornerRadius(20)
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedCat == cat
                                        ? Color.clear
                                        : Color(hex: "#E0E0E0"),
                                    lineWidth: 1
                                )
                        )
                }
            }
        }
    }


    // Start Decision button
   
    private var startButton: some View {
        Button(action: validateAndStart) {
            HStack(spacing: 8) {
                Text("Start Decision")
                    .font(.system(size: 16, weight: .bold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: "#1DB954"))
            .cornerRadius(14)
        }
    }


    // Validation

    //Validates all fields before navigating to the countdown screen.
    private func validateAndStart() {
        errorMessage = ""

        guard !itemName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter an item name."
            return
        }
        guard priceDouble > 0 else {
            errorMessage = "Please enter a valid price greater than 0."
            return
        }
        // All valid — navigate to countdown
        goToCountdown = true
    }
}


// AddPurchaseTabBar


private struct AddPurchaseTabBar: View {
    private let tabs: [(icon: String, label: String, active: Bool)] = [
        ("house",      "Home",     false),
        ("chart.bar",  "History",  false),
        ("calendar",   "Calendar", false),
        ("star.fill",  "Rewards",  true ),
    ]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                let t = tabs[i]
                VStack(spacing: 3) {
                    Image(systemName: t.icon)
                        .font(.system(size: 20, weight: t.active ? .semibold : .regular))
                        .foregroundColor(t.active ? Color(hex: "#1DB954") : Color(hex: "#9E9E9E"))
                    Text(t.label)
                        .font(.system(size: 10, weight: t.active ? .semibold : .regular))
                        .foregroundColor(t.active ? Color(hex: "#1DB954") : Color(hex: "#9E9E9E"))
                    Circle()
                        .fill(t.active ? Color(hex: "#1DB954") : Color.clear)
                        .frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity).padding(.top, 10)
            }
        }
        .frame(height: 60)
        .background(Color.white.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -2))
        .padding(.bottom, (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom) ?? 0)
    }
}




#Preview("Add Purchase") {
    NavigationStack { AddPurchaseView() }
}
