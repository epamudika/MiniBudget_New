//
//  SplashView.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-04-26.
//

import SwiftUI

struct LoadingView: View {
    
    
    // Controls navigation to the Welcome screen.
    @State private var navigateToWelcome = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Background: white/light grey
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    // Piggy bank illustration
                    Image("piggy_bank")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Spacer()
                    
                    //Brand name row
                    VStack(spacing: 6) {
                        Text("Welcome to")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Text("Mini")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            Text("Budget")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.primaryGreen)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            // Navigate to Welcome once isActive becomes true
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
            //  Trigger navigation after 2-second delay
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    navigateToWelcome = true
                }
            }
        }
    }
}

#Preview {
    LoadingView()
}
