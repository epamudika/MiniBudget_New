//
//  ContentView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
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
}

#Preview {
    ContentView()
}
