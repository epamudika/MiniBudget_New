//
//  AddpurchaseView.swift
//  MiniBudget_New
//
//  Created by COBSCCOMP242P-051 on 2026-05-07.
//

import SwiftUI

// Category enum
enum PurchaseCategory: String, CaseIterable {
    case leisure    = "Leisure"
    case essentials = "Essentials"
    case travel     = "Travel"
}

// AddPurchaseView
struct AddPurchaseView: View {

    // Binding to switch tabs from MainTabView
    @Binding var selectedTab: MBTab

    // Form fields
    @State private var itemName     : String           = ""
    @State private var priceText    : String           = ""
    @State private var selectedCat  : PurchaseCategory = .leisure

    // Navigation state
    @State private var goToCountdown: Bool = false

    // Validation error
    @State private var errorMessage : String = ""

    // Computed price
    private var priceDouble: Double { Double(priceText) ?? 0 }

    var body: some View {
        ZStack(alignment: .bottom) {

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Spacer().frame(height: 32)

                    // Headline
                    Text("Add Purchase Idea!")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)

                    // Italic subtitle
                    Text("Think before you buy!")
                        .font(.system(size: 14, weight: .regular))
                        .italic()
                        .foregroundColor(Color(hex: "#1DB954"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 32)

                    // ITEM NAME
                    fieldLabel("ITEM NAME")
                    itemNameField
                        .padding(.bottom, 20)

                    // PRICE
                    fieldLabel("PRICE")
                    priceField
                        .padding(.bottom, 20)

                    // CATEGORY
                    fieldLabel("CATEGORY")
                    categoryChips
                        .padding(.bottom, 32)

                    // Validation error
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 2)
                            .padding(.bottom, 12)
                    }

                    // Start Decision button
                    startButton

                    // Navigate to CountDownView
                    .navigationDestination(isPresented: $goToCountdown) {
                        CountDownView(
                            itemName:    itemName,
                            price:       priceDouble,
                            category:    selectedCat.rawValue,
                            selectedTab: $selectedTab
                        )
                        .navigationBarHidden(true)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.white.ignoresSafeArea())
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }

    // Field label
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(Color(hex: "#9E9E9E"))
            .tracking(0.8)
            .padding(.bottom, 6)
    }

    // Item name field
    private var itemNameField: some View {
        TextField("eg: Snacks", text: $itemName)
            .font(.system(size: 15))
            .foregroundColor(Color(hex: "#1A1A1A"))
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color(hex: "#F0FFF4"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#C8E6C9"), lineWidth: 1)
            )
    }

    // Price field
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

    //Category chips
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

    //Start Decision button
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
        goToCountdown = true
    }
}

#Preview("Add Purchase") {
    NavigationStack {
        AddPurchaseView(selectedTab: .constant(.decision))
    }
}
